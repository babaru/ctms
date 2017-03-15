require 'rails_helper'

RSpec.describe TimeSheet, type: :model do
  describe '#parse_issue_note' do
    it 'return false if note is nil' do
      TimeSheet.parse_issue_note(nil) do |matched, a, b|
        expect(matched).to be false
      end
    end

    it 'return false if note not matched' do
      TimeSheet.parse_issue_note('note') do |matched, a, b|
        expect(matched).to be false
      end
    end

    it 'return true and values if matched' do
      TimeSheet.parse_issue_note('timesheet 2017-03-14 3') do |matched, spent, spent_at|
        expect(matched).to be true
        expect(spent).to eq('3')
        expect(spent_at).to eq('2017-03-14')
      end
    end

    it 'handled string case' do
      TimeSheet.parse_issue_note('timEsheet 2017-03-11 7') do |matched, spent, spent_at|
        expect(matched).to be true
        expect(spent).to eq('7')
        expect(spent_at).to eq('2017-03-11')
      end
    end

    it 'handled blank space' do
      TimeSheet.parse_issue_note('timEsheet 2017-03-12    7') do |matched, spent, spent_at|
        expect(matched).to be true
        expect(spent).to eq('7')
        expect(spent_at).to eq('2017-03-12')
      end
    end

    it 'handled hours mark' do
      TimeSheet.parse_issue_note('timEsheet 2017-03-12  7h') do |matched, spent, spent_at|
        expect(matched).to be true
        expect(spent).to eq('7')
        expect(spent_at).to eq('2017-03-12')
      end
    end
  end
end
