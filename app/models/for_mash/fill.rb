module ForMash
  class Fill
    include Mongoid::Document
    include Mongoid::Timestamps::Created

    # Relations
    belongs_to :creator, polymorphic: true
    belongs_to :template, class_name: 'ForMash::Template'
    embeds_many :entries, cascade_callbacks: true, class_name: 'ForMash::Entry'
    accepts_nested_attributes_for :entries
    has_many :attachments, class_name: 'ForMash::Attachment'
    accepts_nested_attributes_for :attachments

    # Callbacks
    after_validation :flatten_nested_errors

    # Methods
    def label
      @label ||= "#{self.template.name} (#{I18n.l self.created_at, format: :long})"
    end

  protected
    def flatten_nested_errors
      if self.errors[:entries].any?
        self.errors[:entries].clear
        self.entries.each do |entry|
          entry.errors.full_messages.each do |error|
            self.errors[:entries] << error.gsub(/^(?:Value|File)/, entry.label)
          end
        end
      end
    end
  end
end
