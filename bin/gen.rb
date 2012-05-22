$LOAD_PATH.unshift File.dirname( __FILE__ ) + '/../lib'
require 'mustache'
require 'rubygems'
require 'date'
require 'json'
require 'ftools'
require 'Fileutils.rb'

# preparation for mustache
Mustache.template_file = File.dirname( __FILE__ ) + '/../www/template.html'
view = Mustache.new
json_file = File.dirname( __FILE__ ) + '/config.json';
data = JSON.parse( IO.read( json_file ) )

# download button and archives
# releases = data['projects']
# if releases.length > 0
#     latest_item = releases[0]
#     archives = releases.slice(1, releases.length)
#     len = archives.length;
#     column_len = ( len / 3.0 ).ceil
#     view[:download_set1] = archives.slice( 0, column_len )
#     view[:download_set2] = archives.slice( column_len, column_len )
#     view[:download_set3] = archives.slice( column_len*2, column_len )
#     view[:latest_version] = latest_item['version']
#     view[:download_link] = latest_item['file']
#     view[:hide_archives] = len == 0
# else
#     view[:hide_archives] = true
#     view[:no_download] = true
# end

# list of repos
repos = data['projects']

for i in repos
    # print i
    # value["images"]
    # for j in i["images"]
    #         preview = j
    #         thumb = preview.gsub('.', '_thumb.')
    #         value["images"][key1] = {
    #             "thumb" => thumb,
    #             "preview" => preview
    #         }
    #     end
    new_array = []
    uid = i["id"]
    index = 0
    i["images"].each do |j|
       preview = j
       thumb = preview.gsub('.', '_thumb.')
       new_array.push({
           "thumb" => thumb,
           "preview" => preview,
           "uid" => uid
       })
       index += 1
    end
    
    for j in (index..2)
        new_array.push({
            "thumb" => 'empty'
        })
    end
    
    i["images"] = new_array
end


view[:projects] = repos
# view[:repo_platforms][0]['first'] = true
# view[:repo_other] = repos['other']
# view[:repo_other][0]['first'] = true
# 
# # quicklinks / sitemap
# sitemap = data['sitemap']
# view[:links_general] = sitemap['general']
# view[:links_dev] = sitemap['dev']
# view[:links_asf] = sitemap['asf']

view[:year] = Date.today.year

# preparing to generate site
tmp_directory = 'tmp'
Dir.mkdir( tmp_directory ) unless File.exists?( tmp_directory )

# copying files from www
files = Dir.glob( 'www/*' )
FileUtils.cp_r( files, tmp_directory )

# generating index.html
File.open( tmp_directory + '/index.html', 'w' ) do | file | 
    file_data = view.render( data )
    file_data = file_data.gsub( /<\![\s-]{0,5}localstart[^*]+?localend[\s-]{0,5}>|<!--\spublicstart[^<]+|\spublicend[^*]+?-->/, '' )
    file.puts view.render( file_data )
end

# LessCSS
system( "lessc www/css/master.less > " + tmp_directory + "/css/master.css" )

# remove unnecessary files
delete_files = ['/template.html', '/js/local.js', '/js/less-1.1.5.min.js', '/master.less']
for i in delete_files
    File.delete( tmp_directory+i ) unless !File.exists?( tmp_directory+i )
end

# rename tmp folder to public
p_files = Dir.glob( 'public/*' )
FileUtils.rm_rf( p_files ) unless !File.exists?( tmp_directory )
File.rename( tmp_directory, 'public' )

