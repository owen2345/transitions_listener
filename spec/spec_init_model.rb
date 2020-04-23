# frozen_string_literal: true

require 'active_record'
def prepare_database!
  root_path = File.dirname __dir__
  db = 'db/test.sqlite3'
  db_path = File.join(root_path, db)
  File.delete(db_path) if File.exist?(db_path)

  ActiveRecord::Base.logger = Logger.new(STDERR)
  ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    database: db
  )
  migrate!
end

def migrate!
  ActiveRecord::Base.connection.create_table :articles do |table|
    table.column :title, :string
    table.column :state, :string
  end
end

prepare_database!

class Article < ActiveRecord::Base
  include TransitionsListener
  listen_transitions :state do
    before_transition any => any do |article, transition|
      article.log_before(transition)
    end

    after_transition any => any do |article, transition|
      article.log_after(transition)
    end

    before_transition({ any => any }, :any_to_any_callback)
  end

  def any_to_any_callback(_transition)
    puts "any to any callback called"
  end

  # state: active, inactive, deleted

  def log_before(msg)
    puts msg
  end

  def log_after(msg)
    puts msg
  end
end
