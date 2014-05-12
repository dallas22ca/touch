Paperclip::Attachment.default_options.merge!({
  storage: :s3,
  s3_protocol: "https",
  s3_credentials: {
      access_key_id: CONFIG["aws_access_key_id"],
      secret_access_key: CONFIG["aws_secret_access_key"],
      bucket: CONFIG["aws_bucket"]
    },
    s3_headers: {
      cache_control: "max-age=315576000",
      expires: 10.years.from_now.httpdate
    },
  url: "//s3.amazonaws.com/#{CONFIG["aws_bucket"]}/:class/:attachment/:id_partition/:style/:filename",
  path: "/:class/:attachment/:id_partition/:style/:filename"
})