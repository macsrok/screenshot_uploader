# frozen_string_literal: true

class Uploader
  require 'digest'
  require 'aws-sdk-s3'
  require 'mimemagic'
  require 'clipboard'
  require 'http'
  require 'cgi'
  require 'json'

  attr_reader :path, :file, :aws_client

  def initialize(path)
    @path = path
    @file = File.open(path)
    @aws_client = configure_aws
  rescue Errno::ENOENT
    puts 'File not found'
  end

  def upload
    return unless file

    name = Digest::MD5.file(path).hexdigest
    name = "#{name}#{File.extname(path)}"
    put_object(file, name)
    Clipboard.copy shorten_url(presigned_url(name))
  end

  private

  def configure_aws
    Aws.config.update(
      endpoint: ENV['MINIO_ENDPOINT'],
      access_key_id: ENV['MINIO_ACEESS_KEY']  ,
      secret_access_key: ENV['MINIO_SECRETACCESSKEY'],
      force_path_style: true,
      region: 'us-east-1'
    )
    Aws::S3::Client.new
  end

  def bucket
    Aws::S3::Bucket.new(ENV.fetch('MINIO_BUCKET', 'screenshots'))
  end

  def presigned_url(name)
    CGI.escape(bucket.object(name).presigned_url(:get, expires_in: ENV.fetch('MINO_PRESIGNED_EXP', 604_799)))
  end

  def put_object(file, name)
    aws_client.put_object(
      key: name,
      body: file.read,
      bucket: ENV.fetch('MINIO_BUCKET', 'screenshots'),
      content_type: MimeMagic.by_magic(file).type,
      content_disposition: 'inline'
    )
  end

  def shorten_url(url)
    api_url = "https://#{ENV['YOURLS_DOMAIN']}/yourls-api.php?action=shorturl&signature=#{ENV['YOURLS_SIG']}&format=json&url=#{url}"
    JSON.parse(HTTP.get(api_url).body)['shorturl']
  end
end
