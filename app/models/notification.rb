class Notification < ActiveRecord::Base
    belongs_to :user

    attr_accessible :model, :actor, :user, :action, :actor_id, :model_id,
                    :model_type, :text, :user_id

    def self.mark_read
        update_all( { read: true }, { read: false } )
    end

    def self.unread
        where( read: false )
    end

    def read?
        read
    end

    def unread?
        !read?
    end

    def user=( u )
        self.user_id = u.id
    end

    def user
        User.find( user_id )
    end

    def actor=( u )
        self.actor_id = u.id
    end

    def actor
        User.find( actor_id )
    end

    def model=( m )
        self.model_type = m.class.to_s
        self.model_id   = m.id
        m
    end

    def model
        model_type.classify.constantize.find( model_id ) rescue nil
    end

    def action
        super.to_sym
    end

    def past_tense_action
        "was " + case action
            when :destroy, :edit, :abort
                "#{action}ed"
            when :create, :update, :resume, :pause
                "#{action}d"
            else
                action.to_s
        end
    end

    def to_s
        s = model.family.reverse.map do |model|
            "#{model.class} <em>#{model}</em>"
        end.join( ' of ' )

        s + " #{past_tense_action} by #{actor}"
    end

end