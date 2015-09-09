module FlactiveRecord
  class Base

    def self.connection
      DBConnection.instance.connection
    end

    def self.class_name
      Inflecto.demodulize(self.to_s)
    end

    def self.table_name
      Inflecto.pluralize(Inflecto.underscore(self.class_name))
    end

    def self.column_names
      sql = "SELECT column_name FROM information_schema.columns WHERE table_name = '#{self.table_name}'"
      self.connection.exec(sql) do |result|
        result.reduce([]) do |a, row|
      	  a << row["column_name"]
      	end  
      end	
    end	

    def self.all
      sql = "SELECT * FROM #{self.table_name}"
      self.connection.exec(sql) do |result|
      	result.reduce([]) { |a, row| a << self.new(row) }
      end	
    end

    def self.find(id)
      sql = "SELECT * FROM #{self.table_name} WHERE id = $1::int"
      res = self.connection.exec_params(sql, [*id])
      res.count == 0 ? nil : self.new(res[0])
    end  

    def dollar_signs
      cols = self.class.column_names.select{ |e| e != "id" } 
      dollars = []
      cols.size.times do |i|
        dollars << "$#{i+1}"
      end
      dollars.join(", ")   
    end

    def param_values
      self.class.column_names.each_with_object([]) { |e, o| o << {value: self.send(e)} unless e == "id" }
    end  

    def update_with_dollars
      cols = self.class.column_names.select{ |e| e != "id" }
      cols.each_with_index.map { |e, i| "#{e} = $#{i+1}" }.join(", ")
    end

    def insert
      sql = "INSERT INTO #{self.class.table_name} (#{self.class.column_names.select{ |e| e != "id" }.join(", ")}) VALUES (#{dollar_signs}) RETURNING id"
      res = self.class.connection.exec_params(sql, param_values)
      # binding.pry
      @id = res[0]["id"]
    end

    def update
      sql = "UPDATE #{self.class.table_name} SET #{update_with_dollars} WHERE id = #{@id}"
      self.class.connection.exec_params(sql, param_values)
    end

    def save
      id.nil? ? insert : update
    end	

    def self.inherited(successor)
      successor.column_names.each do |e|
        define_method(e) { self.instance_variable_get("@#{e}") }
        define_method("#{e}=") { |v| self.instance_variable_set("@#{e}", v) }
      end  
        	
      define_method(:initialize) do |*args|
        if args[0]
          hash = args[0]
          hash.each { |k,v| self.send("#{k}=", v) }
        end  
      end
    end	
  end
end