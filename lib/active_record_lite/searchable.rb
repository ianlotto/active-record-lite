require_relative './db_connection'

module Searchable
  def where(params)
    columns = params.keys.map { |key| "#{key} = ?" }
    sql = "SELECT * FROM #{table_name} WHERE #{columns.join(" AND ")}"

    parse_all(DBConnection.execute(sql, *params.values))
  end
end