# encoding: utf-8
module Sys::Model::GroupChange::Base

  def truncate_table
    connect = self.class.connection()
    truncate_query = "TRUNCATE TABLE #{self.class.table_name}"
    connect.execute(truncate_query)
  end

end