require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade
  attr_reader :id
  
  def initialize (id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end 

  def self.create_table
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students;
      SQL

    DB[:conn].execute(sql)
  end

  def save
    
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?);
        SQL
    
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create (name, grade)
    student = self.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(query)
    student = self.new(query[0], query[1], query[2])
  end

  def self.find_by_name(name)
    sql = 
      "SELECT * FROM students
      WHERE name = ?;"

    result = DB[:conn].execute(sql, name)[0]
    self.new_from_db(result)
  end 

  def update
    sql =
      "UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?;"

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end


end
