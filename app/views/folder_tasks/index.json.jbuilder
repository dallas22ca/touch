json.array!(@tasks) do |task|
  json.extract! task, :id, :content, :folder_id, :user_id
  json.url task_url(task, format: :json)
end
