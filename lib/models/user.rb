class User < ActiveRecord::Base 
    has_many :events
    has_many :locations, through: :events
    has_many :participants

    def sign_up_event(event)
        Participant.create(user_id: self.id, event_id: event.id)
    end

    def self.register
        prompt= TTY::Prompt.new
        username = prompt.ask("Choose a username")
        name = prompt.ask("What is your name?")
        age = prompt.ask("What is your age?")
        pswd = prompt.mask("Choose a password")
        con_pswd = prompt.mask("Confirm password")
        if pswd == con_pswd
            User.create(username:username, name: name, age: age, password: pswd)
        end
    end

    def self.login
        prompt= TTY::Prompt.new
        username = prompt.ask("What is your username?")
        pswd = prompt.mask("What is your password?")
        user_check = User.find_by(username: username, password:pswd)
        if !user_check
            puts ColorizedString["Incorrect username and/or password!"].red
            self.login
        else 
            user_check.main_menu
        end
    end

    def main_menu
        prompt = TTY::Prompt.new
        choice = prompt.select("Main Menu") do |menu| 
            menu.choice "My Events"
            menu.choice "Upcoming Events"
            menu.choice "Create an Event"
            menu.choice "log out"
        end
        if choice  == "My Events"
            self.my_events
        elsif choice == "Upcoming Events"
            self.show_upcoming_events
        elsif choice == "Create an Event"
            self.create_event
        elsif choice == "log out"
            Interface.welcome
            Interface.login_or_register
        end
    end

    def show_upcoming_events
        prompt = TTY::Prompt.new
       choices = prompt.multi_select("Select event(s)", Event.upcoming_events)
        selected_choices(choices).each{ |choice| sign_up(choice)}
       
    end

    def selected_choices(choices)
        choices.map do |choice|
            choice.split(", ")
        end
    end

    def sign_up(choice) 
        event = Event.find_by(name: choice[0], date: choice[3].to_datetime)
        Participant.create(user_id: self.id, event_id: event.id)
    end

    def my_events
        events = self.events.map do |event|
            "Event: ".colorize(:red) + "#{event.name}\n" + "Location: ".colorize(:red) + "#{event.location.name}\n" + "Date: ".colorize(:red) + "#{event.date}" + " Price: ".colorize(:red) + "$#{event.price}"
        end
        puts events
    end

    def create_event
        prompt = TTY::Prompt.new
        location_choice = prompt.select("Select location", Location.names)
    end





end
