class Ey::Core::Client::Tasks < Ey::Core::Collection

  model Ey::Core::Client::Task

  self.collection_request = :get_tasks
  self.collection_root    = "tasks"
  self.model_request      = :get_task
  self.model_root         = "task"
end
