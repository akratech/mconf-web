# This migration will find all the attachments being used by spaces and generate
# new ones using the new libraries we use.

class GenerateNewAttachments < ActiveRecord::Migration
  def up
    # select all attachments
    # there's no Logo model anymore, so we have to do a raw sql
    att = Attachment.all
    puts "GenerateNewAttachments: found a total of #{att.count} attachments"

    thumbnail = 0
    without_target = 0
    with_target = 0
    succeeded = 0
    failed = 0

    att.each do |a|

      if a.parent_id.present? && a.thumbnail.present?
        thumbnail += 1
        a.delete
        # don't migrate and delete thumbnail attachments
      else
        target = a.space
        if target.nil?
          without_target += 1
          puts "GenerateNewAttachments: WARN: Migration found an attachment without a proper owner, it will be lost"
          puts " #{a.inspect}"
        else
          with_target += 1

          path = old_path(a)
          puts "GenerateNewAttachments: attachment of space #{target.name} is at \"#{path}\", and exists? #{File.file?(path)}"

          if File.file?(path)
            a.attachment = File.open(path)
            # some models might not be with all their data correct so we have to consider that save can fail
            if a.save
              succeeded += 1
              puts " attachment generated successfully!"
            else
              failed += 1
              puts " error saving the attachment: #{a.errors.full_messages}"
            end
          else
            failed += 1
            puts " the file does not exist or is not a file, logo will be lost!"
          end
        end
      end
    end

    puts "----------------------------------------------------------------------------------------"
    puts "GenerateNewAttachments: attachments that had a proper associated space: #{with_target}"
    puts " succeeded: #{succeeded}"
    puts " failed: #{failed}"
    puts "GenerateNewAttachments: attachments that did NOT have a proper associated space: #{without_target}"
    puts "----------------------------------------------------------------------------------------"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

def old_path(att)
  fullid = "%08d" % att.id
  "attachments/#{fullid[0..3]}/#{fullid[4..7]}/#{att.title}"
end