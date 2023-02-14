class Application

	def initialize()
		# parse options for xls file
		@options = parse_options
		@template = JSON.parse(File.read(ENV['TEMPLATE_FILE']))

		@results = process_sheet(@options[:xls_file])
	end

private

	def process_sheet(file)
		xls = Roo::Spreadsheet.open(file)
		results = []

		#xls.each(summary: 'Summary', Reporter: "Reporter", description: "Description", acceptance: "Acceptance Criteria", epic_link: "Epic Link", labels: "Labels") do |row|
		xls.each(epic_link: 'epic_link', summary: 'summary', description: "description", acceptance: "acceptance", size: "size", team: "team", labels: "labels") do |row|
			if valid_row?(row)
				payload = merge_row(@template, row)
				results << post_ticket(payload)

				update_progress(file, results)
			end
		end

		results
	end

	def update_progress(file, results)
		pp results.last
		puts "\n\n"
		File.write("#{file}.json", JSON.pretty_generate(results))
	end

	def parse_options
		options = {}
		optparse = OptionParser.new do |parser|
			parser.on('-f', '--excel_file=FILE') do |file|
				options[:xls_file]=file
			end
		end
		optparse.parse!

		if options[:xls_file].nil?
		  abort(optparse.help)
		end
		abort("#{options[:xls_file]} does not exist") unless File.exists?(options[:xls_file])

		options
	end

	def valid_row?(row)
		row[:summary] && row[:summary].downcase != "summary"
	end

	def merge_row(template,row)
		# There is a bug in the V3 api that prevents markdown being interpreted
		# https://jira.atlassian.com/browse/JRACLOUD-72071
		# Workaround is to use V2 api

		binding.pry
		template['fields'] = template['fields'].transform_keys { |k| k == "CF_EPIC" ? ENV['CF_EPIC'] : k }
		template['fields'] = template['fields'].transform_keys { |k| k == "CF_TEAM" ? ENV['CF_TEAM'] : k }
		template['fields'] = template['fields'].transform_keys { |k| k == "CF_SIZE" ? ENV['CF_SIZE'] : k }
		template['fields'] = template['fields'].transform_keys { |k| k == "CF_AC" ? ENV['CF_AC'] : k }

		template['fields']['summary'] = row[:summary]
		template['fields']['issuetype']['id'] = ENV['STORY_TYPE_ID']
		template['fields']['project']['key'] = ENV['ORG_ID']
		template['fields']['description'] = row[:description]
		template['fields'][ENV['CF_TEAM']]=row[:team] || ENV['TEAM_ID']
    	template['fields'][ENV['CF_EPIC']]=row[:epic_link] || ENV['EPIC_ID']
		template['fields'][ENV['CF_SIZE']]["value"]=row[:size] || ENV['SIZE']
		template['fields'][ENV['CF_AC']]=row[:acceptance]
    	template['fields']["labels"]=row[:labels]&.split(', ')

		template
	end

	def post_ticket(payload)
		jira_result = {}
		RestClient::Request.new(
			:method => :post,
			:url => ENV['JIRA_API_URL'],
			:user => ENV['JIRA_USER'],
			:password => ENV['JIRA_API_TOKEN'],
			:payload => payload.to_json,
			:headers => { :accept => :json, :content_type => :json }
		).execute do |response, request, result|
			jira_result = JSON.parse(response.body) rescue {}
			jira_result["summary"] = payload['fields']['summary']
		end

		jira_result
	end

end