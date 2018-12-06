# Copyright 2018 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def job_discovery_generate_featured_job company_name:
  # [START generate_featured_job]

  require "google/apis/jobs_v3"
  require "securerandom"
  # Instantiate the client
  jobs = Google::Apis::JobsV3

  talent_solution_client = jobs::CloudTalentSolutionService.new
  # @see
  # https://developers.google.com/identity/protocols/application-default-credentials#callingruby
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )

  application_info = jobs::ApplicationInfo.new uris: ["http://careers.google.com"]
  job_generated = jobs::Job.new requisition_id: "jobWithRequiredFields: #{SecureRandom.hex}",
				                title: " Lab Technician",
				                company_name: company_name,
				                application_info: application_info,
				                description: "Design, develop, test, deploy, "\
				                             "maintain and improve software."
  # Featured job is the job with positive promotion value
  job_generated.promotion_value = 2
  puts "Featured Job generated: #{job_generated.to_json}"
  return job_generated
  # [END generate_featured_job]
end

def job_discovery_featured_jobs_search company_name:, query:, project_id:
  # [START search_featured_job]

  require "google/apis/jobs_v3"
  # Instantiate the client
  jobs = Google::Apis::JobsV3

  talent_solution_client = jobs::CloudTalentSolutionService.new
  # @see
  # https://developers.google.com/identity/protocols/application-default-credentials#callingruby
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )

  # Make sure to set the request_metadata the same as the associated search request
  request_metadata = jobs::RequestMetadata.new user_id: "HashedUserId",
						                       session_id: "HashedSessionId",
						                       domain: "www.google.com"

  # Perform a search for analyst  related jobs
  job_query = jobs::JobQuery.new query: query
  if !company_name.nil?
    job_query.company_names = [company_name]
  end

  search_jobs_request = jobs::SearchJobsRequest.new request_metadata: request_metadata,
						                            job_query: job_query,
						                            search_mode: "FEATURED_JOB_SEARCH"

  search_jobs_response = talent_solution_client.search_jobs(project_id, search_jobs_request)

  puts search_jobs_response.to_json
  # [END search_featured_job]
end

def run_featured_job_sample arguments

  require_relative "basic_company_sample"
  require_relative "basic_job_sample"

  command = arguments.shift
  default_project_id = "projects/#{ENV["GOOGLE_CLOUD_PROJECT"]}"
  company_name = "#{default_project_id}/companies/#{arguments.shift}"

  case command
  when "featured_jobs_search"
    company_got_test = job_discovery_get_company company_name: company_name
    job_generated_test = job_discovery_generate_featured_job company_name: company_name
    job_created_test = job_discovery_create_job job_to_be_created: job_generated_test,
                          						project_id: default_project_id
    job_discovery_featured_jobs_search company_name:company_name,
				                       query:arguments.shift,
				                       project_id: default_project_id
  else
  puts <<-usage
Usage: bundle exec ruby featured_job_sample.rb [command] [arguments]
Commands:
  featured_jobs_search       <company_id><query>    Query a featured job under a provided company.
Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
usage
  end
end

if __FILE__ == $PROGRAM_NAME
  run_featured_job_sample ARGV
end
