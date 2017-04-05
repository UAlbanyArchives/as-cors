# Comma-separated list of ArchivesSpace API endpoints you want accessible via Javascript
CORS_ENDPOINTS = ['/version', '/users/current-user', '/repositories/:repo_id/find_by_id/archival_objects', '/repositories/:repo_id/archival_objects/:id', '/repositories/:repo_id/resources/:id', '/repositories/:repo_id/search', '/locations/:id', '/repositories/:repo_id/resources/:id/tree', '/repositories/:repo_id/top_containers']

class CORSMiddleware

  def initialize(app)
    @app = app
    @patterns = build_patterns(CORS_ENDPOINTS)
  end

  def call(env)
    result = @app.call(env)

    # Add CORS headers to specific endpoints
    if env['REQUEST_METHOD'] == 'GET' &&
       result[0] == 200 &&
       @patterns.any? {|pattern| env['PATH_INFO'] =~ pattern}

      # Add CORS headers
      headers = result[1]
      headers["Access-Control-Allow-Origin"] =  "*" # This should be changed
      headers["Access-Control-Allow-Methods"] = "GET, POST"
      headers["Access-Control-Allow-Headers"] = "X-ArchivesSpace-Session, Content-Type"
    end
	
	 # Add CORS headers to specific endpoints
    if env['REQUEST_METHOD'] == 'POST' &&
       result[0] == 200 &&
       @patterns.any? {|pattern| env['PATH_INFO'] =~ pattern}

      # Add CORS headers
      headers = result[1]
      headers["Access-Control-Allow-Origin"] =  "*" # This should be changed
      headers["Access-Control-Allow-Methods"] = "GET, POST"
      headers["Access-Control-Allow-Headers"] = "X-ArchivesSpace-Session, Content-Type"
    end

    result
  end

  private

  def build_patterns(uri_templates)
    uri_templates.map {|uri|
      regex = uri.gsub(/:[a-z_]+/, '[^/]+')
      Regexp.compile("\\A#{regex}$\\z")}
  end

end


# Support OPTIONS, which is necessary for certain browsers (for example Google Chrome)
CORS_ENDPOINTS.each do |uri|
  ArchivesSpaceService.options uri do
    response.headers["Access-Control-Allow-Origin"] = "*"  # This should be changed
    response.headers["Access-Control-Allow-Methods"] = "GET, POST"
    response.headers["Access-Control-Allow-Headers"] = "X-ArchivesSpace-Session,  Content-Type"

    halt 200
  end
end

# Add Rack middleware to ArchivesSpace
ArchivesSpaceService.use(CORSMiddleware)
