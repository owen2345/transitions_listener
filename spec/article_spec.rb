# frozen_string_literal: true

RSpec.describe Article, type: :model do
  let(:article) { Article.create(title: 'Title', state: 'active') }
  before { allow(article).to receive(:log_before) }
  before { allow(article).to receive(:log_after) }

  describe 'before transitions' do
    it 'any to any' do
      expected_trans = hash_including(:from, :to)
      expect(article).to receive(:log_before).with(expected_trans)
      article.update(state: 'inactive')
    end

    it 'verify new/old states' do
      old_state = article.state
      new_state = 'inactive'
      expected_trans = hash_including(from: old_state, to: new_state)
      expect(article).to receive(:log_before).with(expected_trans)
      article.update(state: new_state)
    end

    it 'use model method as the listener callback' do
      expect(article).to receive(:any_to_any_callback)
      article.update(state: 'inactive')
    end
  end

  describe 'after transitions' do
    it 'any to any' do
      expected_trans = hash_including(:from, :to)
      expect(article).to receive(:log_after).with(expected_trans)
      article.update(state: 'inactive')
    end

    it 'verify new/old states' do
      old_state = article.state
      new_state = 'inactive'
      expected_trans = hash_including(from: old_state, to: new_state)
      expect(article).to receive(:log_after).with(expected_trans)
      article.update(state: new_state)
    end
  end
end
