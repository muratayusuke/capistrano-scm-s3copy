namespace :s3copy do
  require 'aws-sdk'

  archive_name = 'archive.tar.gz'
  include_dir  = fetch(:include_dir) || '*'
  exclude_dir  = Array(fetch(:exclude_dir))
  exclude_args = exclude_dir.map { |dir| "--exclude '#{dir}'" }
  s3 = Aws::S3::Client.new

  s3_dir = fetch(:s3_dir, fetch(:stage)).to_s
  s3_path = File.join(s3_dir, archive_name)
  bucket = fetch :s3_bucket

  Aws.config.update(
    access_key_id: fetch(:aws_access_key_id, ENV['AWS_ACCESS_KEY_ID']),
    secret_access_key: fetch(:aws_secret_access_key, ENV['AWS_SECRET_ACCESS_KEY']),
    region: fetch(:aws_region, ENV['AWS_REGION'])
  )

  # Defalut to :all roles
  tar_roles = fetch(:tar_roles, :all)

  desc "Archive files to #{archive_name}"
  file archive_name => FileList[include_dir].exclude(archive_name) do |t|
    tar_verbose = fetch(:tar_verbose, true) ? 'v' : ''
    cmd = ["tar -c#{tar_verbose}zf #{t.name}", *exclude_args, *t.prerequisites]
    sh cmd.join(' ')
  end

  task upload_tarball: archive_name do |t|
    tarball = t.prerequisites.first
    File.open(tarball, 'rb') do |file|
      s3.put_object(bucket: bucket, body: file, key: s3_path)
    end
  end

  task :create_release do
    if fetch(:upload_tarball, true)
      invoke 's3copy:upload_tarball'
    else
      File.open(archive_name, 'wb') do |file|
        p s3.get_object({ bucket: fetch(:s3_bucket), key: s3_path }, target: file)
      end
    end

    on roles(tar_roles) do
      # Make sure the release directory exists
      puts "==> release_path: #{release_path} is created on #{tar_roles} roles <=="
      execute :mkdir, '-p', release_path

      # Create a temporary file on the server
      tmp_file = capture('mktemp')

      # Upload the archive, extract it and finally remove the tmp_file
      upload!(archive_name, tmp_file)
      execute :tar, '-xzf', tmp_file, '-C', release_path
      execute :rm, tmp_file
    end
  end

  task :clean do
    # Delete the local archive
    File.delete archive_name if File.exist? archive_name
  end

  after 'deploy:finished', 's3copy:clean'

  task :check
  task :set_current_revision
end
