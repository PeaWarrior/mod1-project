class User < ActiveRecord::Base 
    has_many :events
    has_many :locations, through: :events
    has_many :participants

    
    def self.register
        prompt = TTY::Prompt.new
        username = prompt.ask("Choose a username")
        name = prompt.ask("What is your name?")
        dob = self.ask_dob
        pswd = self.register_password
        self.successful_registration(username, name, dob, pswd)
    end

    def self.register_password
        prompt = TTY::Prompt.new
        pswd = prompt.mask("Create a password")
        con_pswd = prompt.mask("Confirm password")
        pswd == con_pswd ? pswd : self.register_password_unmatched
    end

    def self.register_password_unmatched
        puts "Passwords did not match, please try again.".colorize(:red)
        sleep(2)
        print "\r" + ("\e[A\e[K"*3)
        self.register_password
    end

    def self.successful_registration(username, name, dob, pswd)
        puts "Account successfully created!".colorize(:green)
        sleep(2)
        User.create(username: username, name: name, dob: dob, password: pswd)
    end

    def self.ask_dob
        prompt = TTY::Prompt.new
        user_dob = prompt.ask("What is your date of birth?\n", value: "MM/DD/YYYY\r ".colorize(:light_black)) do |question|
            question.validate (/\d{1,2}\/\d{1,2}\/\d{4}/)
        end
        dob = user_dob.split("/").map do |element|
            element.to_i
        end
        if !Date.valid_date?(dob[2], dob[0], dob[1])
            puts "Please enter a valid date of birth.".colorize(:red)
            self.ask_dob
        end
        if (Time.now.strftime('%Y%m%d').to_i - Time.new(dob[2], dob[0], dob[1]).strftime('%Y%m%d').to_i)/10000 < 18
            puts "Sorry, you must be 18 or older to join."
            sleep(2)
            interface = Interface.new()
            interface.welcome
            user_instance = interface.login_or_register
            interface.user = user_instance
            interface.main_menu
        else user_dob
        end
    end
    
    def self.login
        prompt= TTY::Prompt.new
        username = prompt.ask("What is your username?")
        pswd = prompt.mask("What is your password?")
        found_user = User.find_by(username: username, password:pswd)
        found_user ? found_user : self.incorrect_username_or_password
    end

    def self.incorrect_username_or_password
        puts ColorizedString["Incorrect username and/or password!"].red
        self.login
    end

    def update_name 
        prompt = TTY::Prompt.new
        name_update = prompt.ask(" New name:")
        self.update(name: name_update)
        puts ColorizedString["Name has been updated to #{name_update}!"].green
      
    end

    def update_age
        prompt = TTY::Prompt.new
        age_update = prompt.ask("DOB MM/DD/YYY:")
        birthday = Date.new(age_update)
        ac = AgeCalculator.new(birthday)
        binding.pry
        self.update(age: ac)
        puts ColorizedString["Age has been updated to #{age_update}!"].green
        
    end

    def change_password
        prompt = TTY::Prompt.new
        current_pswd = prompt.mask("What is your current password?")
        new_pswd = prompt.mask("What is your new password?")
        confirm_new_pswd = prompt.mask("Please confirm new password")
        if current_pswd == self.password && new_pswd == confirm_new_pswd
            self.update(password: new_pswd)
            puts ColorizedString["Your password has been updated!"].green 

         else
            puts ColorizedString["Incorrect password  or new password does not match!"].red 
        
        end 
    
    end

     def delete_account
        prompt = TTY::Prompt.new
        prompt.warn("WARNING: Action can not be undone.")
        choice = prompt.select("Are you sure you want to delete this account") do |menu|
            menu.choice "Yes", -> {
                pswd = prompt.mask("What is your password?")
                if pswd == self.password
                    self.destroy
                    new_inter = Interface.new
                    puts ColorizedString["ACCOUNT DESTROYED"].red 
                    sleep(3)
                    new_inter.welcome
                    new_inter.login_or_register
                else
                    puts ColorizedString["Incorrect password"].red 
                end
            }
            menu.choice "No" 
        end
    end
            
end

