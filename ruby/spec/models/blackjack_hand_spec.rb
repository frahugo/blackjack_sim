require File.dirname(__FILE__) + "/" + '../../app/models/blackjack_hand.rb'

describe BlackjackHand do

  context 'is_soft_17?' do

    before(:each) do
      @ace = Card.new(:diamond,:ace)
      @ace2 = Card.new(:diamond,:ace)
      @ten = Card.new(:spade,:queen)
      @seven = Card.new(:spade, 7)
      @six = Card.new(:spade, 6)
      @five = Card.new(:spade, 5)
      @two = Card.new(:spade, 2)
    end

    it 'should handle under 17 correctly' do
      hand = BlackjackHand.new(@ace,@two)
      hand.is_soft_17?.should be_false
    end

    it 'should handle over 17 correctly' do
      hand = BlackjackHand.new(@ace,@seven)
      hand.is_soft_17?.should be_false
    end

    it 'should handle soft 17 correctly with one ace' do
      hand = BlackjackHand.new(@ace,@six)
      hand.is_soft_17?.should be_true
    end

    it 'should handle soft 17 with multiple aces' do
      hand = BlackjackHand.new(@ace,@five)
      hand << @ace2
      hand.is_soft_17?.should be_true
    end
  end

  context 'blackjack?' do
    before(:each) do
      @ace = Card.new(:diamond,:ace)
      @ten = Card.new(:spade,:queen)
      @seven = Card.new(:spade, 7)
    end

    it "should return yes if blackjack hand" do
      hand = BlackjackHand.new(@ace, @ten)
      hand.blackjack?.should be_true
    end

    it "should return not if not blackjack hand" do
      hand = BlackjackHand.new(@ace, @seven)
      hand.blackjack?.should be_false
    end

    it "should return not if more than 2 cards in hand" do
      hand = BlackjackHand.new(@ace, @ten)
      hand << @seven
      hand.blackjack?.should be_false
    end
  end

  it 'should construct with the two initial hand cards' do

    card_one = Card.new(:diamond,1)
    card_two = Card.new(:spade,1)
    card_three = Card.new(:spade,5)


    blackjack_hand = BlackjackHand.new(card_one,card_two)
    cards = blackjack_hand.cards

    cards.index(card_one).should_not be_nil
    cards.index(card_two).should_not be_nil
    cards.index(card_three).should be_nil

  end

  it 'should be able to determine if it is a pair hand' do
    card_one = Card.new(:diamond, 2)
    card_two = Card.new(:spade, 2)
    card_three = Card.new(:club, 4)

    blackjack_hand = BlackjackHand.new(card_one, card_two)

    blackjack_hand.is_pair?.should be_true

    blackjack_hand = BlackjackHand.new(card_one, card_three)

    blackjack_hand.is_pair?.should be_false
  end

  context 'get_strategy_key' do
    before(:all) do
      @five = Card.new :spade,5
      @five2 = Card.new :diamond,5
      @ace = Card.new :diamond,:ace
      @ace2 = Card.new :spade,:ace
      @four = Card.new :diamond,4
      @three = Card.new :diamond,3
      @queen1 = Card.new :diamond, :queen
      @queen2 = Card.new :spade, :queen
      @jack = Card.new :spade, :jack
    end

    it 'should return the correct key given two queens' do
      hand = BlackjackHand.new @queen1, @queen2
      hand.get_strategy_key.to_s.should eql("1010")
    end

    it 'should return the correct key given two face cards' do
      hand = BlackjackHand.new @queen1, @jack
      hand.get_strategy_key.to_s.should eql("20")
    end

    it 'should return the correct key given an ace hand' do
      hand = BlackjackHand.new @ace, @four
      hand.get_strategy_key.to_s.should eql("A4")
		end

		it 'should return the correct key given a pair hand' do
      hand = BlackjackHand.new @five, @five2
      hand.get_strategy_key.to_s.should eql("55")
		end

		it 'should return the correct key given an ace with two face cards that add under 10' do
      hand = BlackjackHand.new @five, @ace
      hand << @four
      hand.get_strategy_key.to_s.should eql("A9")
		end

    it 'should return the correct key given two aces with two face cards that add under 10' do
      hand = BlackjackHand.new @five, @ace
      hand << @ace2
      hand << @three
      hand.get_strategy_key.to_s.should eql("A9")
    end

	end


  context 'hand_value' do
    it 'should handle blackjack correctly' do
      ace_card = Card.new(:diamond,:ace)
      face_card = Card.new(:spade,:king)
      open_card = Card.new(:club,5)

      hand = BlackjackHand.new ace_card,face_card
      hand.hand_value.should eq(21)
    end

    it 'should handle 21 correctly' do
      ace_card = Card.new(:diamond,:ace)
      ten_card = Card.new(:spade,:king)
      ten_card2 = Card.new(:club, :queen)

      hand = BlackjackHand.new ace_card,ten_card
      hand << ten_card2

      hand.hand_value.should eq(21)
    end

    it 'should handle two aces' do
      ace_card = Card.new(:diamond,:ace)
      ace_card2 = Card.new(:spade,:ace)
      open_card = Card.new(:club,2)

      hand = BlackjackHand.new ace_card,ace_card2
      hand << open_card

      hand.hand_value.should eq(14)
    end

    it 'should use ace for best score' do
      ace_card = Card.new(:diamond,:ace)
      five = Card.new(:spade,5)
      two = Card.new(:club, 2)

      hand = BlackjackHand.new five, two
      hand << ace_card

      hand.hand_value.should eq(18)
    end
  end

  context 'get_strategy' do

    before(:all) do
      # @strategy = {:A3 => {"3".to_sym => :hit},"15".to_sym => {"3".to_sym => :double,:ace => :stay}, "17".to_sym => {"3".to_sym => :stay}}
      @strategy = StrategyUtil.load_strategies
    end

    it 'should return correct strategy if players hand contains a face card' do
       player = BlackjackHand.new(Card.new(:spade,:queen),Card.new(:diamond, 7))
       dealer_card = Card.new(:spade, 3)
       player.get_strategy(dealer_card,@strategy).should eql(:stay)
    end

    context 'should return correct strategy with dealer showing ace' do

      it 'should return hit when necessary' do
        dealer_card = Card.new(:spade, :ace)
        players_cards = BlackjackHand.new(Card.new(:spade, :ace), Card.new(:diamond, 3))

        players_cards.get_strategy(dealer_card,@strategy).should eql(:hit)
      end

      it 'should return hit even though double is the correct strategy if it is not the players initial hand' do
        dealer_card = Card.new(:spade, :ace)
        players_cards = BlackjackHand.new(Card.new(:spade, :ace), Card.new(:diamond, 3))
        players_cards << Card.new(:spade, :ace)
        players_cards.get_strategy(dealer_card,@strategy).should eql(:hit)
      end

      it 'should double when necessary' do
        dealer_card = Card.new(:spade, 6)
        players_cards = BlackjackHand.new(Card.new(:spade, :ace), Card.new(:spade, 5))
        players_cards.get_strategy(dealer_card, @strategy).should eql(:double)
      end

      it 'should do the right thing if dealer is showing an ace' do
        dealer_card = Card.new(:spade, :ace)

        players_cards = BlackjackHand.new(Card.new(:space, :queen), Card.new(:diamond, 5))
        players_cards.get_strategy(dealer_card, @strategy).should eql(:hit)
      end

    end

    context "with a pair" do
      it 'should return hit against an ace' do
        dealer_card = Card.new(:spade, :ace)
        players_cards = BlackjackHand.new(Card.new(:spade, 3), Card.new(:diamond, 3))

        players_cards.get_strategy(dealer_card,@strategy).should eql(:hit)
      end

      it 'should return split against a 4' do
        dealer_card = Card.new(:spade, 4)
        players_cards = BlackjackHand.new(Card.new(:spade, 3), Card.new(:diamond, 3))

        players_cards.get_strategy(dealer_card,@strategy).should eql(:split)
      end
    end

    context "with surrender" do
      it 'should return hit against an ace' do
        dealer_card = Card.new(:spade, :ace)
        players_cards = BlackjackHand.new(Card.new(:spade, 6), Card.new(:diamond, 10))

        players_cards.get_strategy(dealer_card,@strategy).should eql(:surrender)
      end
    end

  end
end
