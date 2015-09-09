class State < FlactiveRecord::Base
end

class Programmer < FlactiveRecord::Base
end


describe "Metaprogrammed Amazingness" do
  DBConnection.instance.dbname = 'dynamic_orm_test'
  CONN = DBConnection.instance.connection

  context "superclass" do
    it "exists" do
      expect{FlactiveRecord::Base}.to_not raise_error
    end

    it "returns the connection to the database" do
      expect(FlactiveRecord::Base.connection).to be_a PG::Connection
    end

    it "connects to localhost" do
      connection = FlactiveRecord::Base.connection
      expect(connection.host).to eq("localhost")
    end

    it "connects to the test database" do
      connection = FlactiveRecord::Base.connection
      expect(connection.db).to eq("dynamic_orm_test")
    end
  end

  context "Programmers" do
    before do
      seed_data = File.read('spec/db/programmer_seed.sql')
      CONN.exec(seed_data)
    end

    after do
      CONN.exec("DROP TABLE programmers;")
    end

    context "About the Table" do
      it "knows its table" do
        expect(Programmer.table_name).to eq('programmers')
      end

      it "knows its columns" do
        expect(Programmer.column_names).to eq(["id", "name", "language"])
      end
    end

    context "Instances" do
      it "defines methods based on the columns" do
        steven_nunez = Programmer.new
        steven_nunez.name = "Steven Nunez"
        steven_nunez.language = "Loves teh rubiez"

        expect(steven_nunez.name)
        expect(steven_nunez.language)
      end

      it "can create instances with a hash" do
        john_mcarthy = Programmer.new(name: "John McCarthy", language: 'lisp')
        expect(john_mcarthy.name).to eq("John McCarthy")
        expect(john_mcarthy.language).to eq('lisp')
      end

      it "initializes without an id" do
        john_mcarthy = Programmer.new(name: "John McCarthy", language: 'lisp')
        expect(john_mcarthy.id).to be_nil
      end
    end

    context "finders" do
      it "returns all programmers" do
        programmers = Programmer.all
        # From the seed file
        expect(programmers.count).to eq(3)
        expect(programmers.first).to be_a Programmer
      end

      it "finds a single programmer by id" do
        programmer = Programmer.find(1)
        expect(programmer.name).to eq("Yukihiro Matzumoto")
      end

      it "returns nil if a programmer isn't found" do
        programmer = Programmer.find(9001)
        expect(programmer).to be_nil
      end
    end

    context "saving and updating a programmer" do
      it "saves an non existent programmer" do
        programmer = Programmer.new(name: "Steven", language: "Ruby")
        programmer.save
        # binding.pry
        expect(programmer.id).to_not be_nil
      end

      it "updates a programmers name" do
        programmer = Programmer.find(1)
        programmer.name = "Tenderlove"
        programmer.save

        found_programmer = Programmer.find(1)
        expect(found_programmer.name).to eq('Tenderlove')
      end
    end
  end
  context "States" do

    before do
      seed_data = File.read('spec/db/state_seed.sql')
      CONN.exec(seed_data)
    end

    after do
      CONN.exec("DROP TABLE states;")
    end
    context "About the Table" do
      it "knows its table" do
        expect(State.table_name).to eq('states')
      end

      it "knows its columns" do
        expect(State.column_names).to eq(["id", "name", "rank", "density_per_square_mile"])
      end
    end

    context "Instances" do
      it "defines methods based on the columns" do
        new_york = State.new
        new_york.name = "New York"
        new_york.rank = 1
        new_york.density_per_square_mile = 90000000

        expect(new_york.name).to eq('New York')
        expect(new_york.rank).to eq(1)
        expect(new_york.density_per_square_mile).to eq 90000000
      end

      it "can create instances with a hash" do
        new_york = State.new(name: "New York", rank: 1, density_per_square_mile: 90000000)
        expect(new_york.name).to eq("New York")
        expect(new_york.rank).to eq(1)
        expect(new_york.density_per_square_mile).to eq(90000000)
      end

      it "initializes without an id" do
        new_york = State.new(name: "New York", rank: 1, density_per_square_mile: 90000000)
        expect(new_york.id).to be_nil
      end
    end

    context "finders" do
      it "returns all programmers" do
        state = State.all
        # From the seed file
        expect(state.count).to eq(10)
        expect(state.first).to be_a State
      end

      it "finds a single programmer by id" do
        state = State.find(1)
        expect(state.name).to eq("New Jersey")
      end

      it "returns nil if a programmer isn't found" do
        state = State.find(9001)
        expect(state).to be_nil
      end
    end

    context "saving and updating a programmer" do
      it "saves an non existent programmer" do
        new_york = State.new(name: "Steven", rank: 1, density_per_square_mile: 9000000)
        new_york.save
        expect(new_york.id).to_not be_nil
      end

      it "updates a programmers name" do
        new_york = State.find(1)
        new_york.name = "New York"
        new_york.save

        found_state = State.find(1)
        expect(found_state.name).to eq('New York')
      end
    end
  end
end
