require File.dirname(__FILE__) + "/models/" + 'shoe.rb'
require File.dirname(__FILE__) + "/models/" + 'blackjack_hand.rb'
require File.dirname(__FILE__) + "/util/" + 'strategy_util.rb'
require 'yaml'

class BlackjackGame

  attr_accessor :num_losses,:num_wins,:num_pushes,:total_winnings

  def initialize num_hands, bet_size, shoe_size
    @strategies = StrategyUtil.load_strategies
    @num_hands = num_hands
    @bet_size = bet_size
    @shoe = Shoe.new shoe_size
    @num_losses = 0
    @num_wins = 0
    @num_pushes = 0
    @num_surrenders = 0
    @total_winnings = 0
    @highest_winnings = 0
    @lowest_winnings = 0
  end

  def play_game
    @num_hands.times  {
      dealerHand = BlackjackHand.new @shoe.deal_card, @shoe.deal_card
      playerHand = BlackjackHand.new @shoe.deal_card, @shoe.deal_card

      play_hand(dealerHand, playerHand,@bet_size)
      log "Winnings: #{@total_winnings}"
      log "------------------------------------------------------------"

      @shoe.burn_cards
    }
  end

  def to_s
    "#{@num_wins} wins, #{@num_losses} losses, #{@num_pushes} pushes, #{@num_surrenders} surrenders.\nTotal Winnings: #{@total_winnings} [#{@lowest_winnings}, #{@highest_winnings}]\nWin/Loss: #{@num_wins/@num_losses.to_f}"
  end

  def log message
    # puts message
  end

  def dp dealerHand, playerHand
    "Playerhand #{playerHand}=#{playerHand.hand_value}  Dealerhand: #{dealerHand}=#{dealerHand.hand_value}"
  end

  def dps dealerHand, playerHand
    "Playerhand #{playerHand}=#{playerHand.hand_value}  Dealerhand: #{dealerHand.hand[0]}"
  end

  private

  def play_hand dealerHand, playerHand, curr_bet_size
    log "Playing hand... #{dps dealerHand, playerHand}"
    show_card = dealerHand.hand[0]

    if (playerHand.hand_value > 21)
      log "BUSTED! #{dp dealerHand, playerHand}"
      @num_losses = @num_losses + 1
      @total_winnings = @total_winnings - curr_bet_size
      return
    elsif playerHand.blackjack?
      if dealerHand.blackjack?
        log "PUSH! #{dp dealerHand, playerHand}"
        @num_pushes = @num_pushes + 1
      else
        log "BLACKJACK! #{dp dealerHand, playerHand}"
        @num_wins = @num_wins + 1
        @total_winnings = @total_winnings + (curr_bet_size * 3/2.to_f)
      end
      return
    elsif dealerHand.blackjack?
      log "DEALER HAS BLACKJACK! #{dp dealerHand, playerHand}"
      @num_losses = @num_losses + 1
      @total_winnings = @total_winnings - curr_bet_size
      return
    end

    strat = playerHand.get_strategy show_card, @strategies
    hand_result = nil
    if (strat == :split)
      log "SPLITTING #{dps dealerHand, playerHand}"
      play_hand(dealerHand, BlackjackHand.new(playerHand.hand[0], @shoe.deal_card), curr_bet_size)
      play_hand(dealerHand, BlackjackHand.new(playerHand.hand[1], @shoe.deal_card), curr_bet_size)
    elsif strat == :double
      log "DOUBLING"
      playerHand << @shoe.deal_card
      curr_bet_size = curr_bet_size * 2
      hand_result = finish_hand(dealerHand, playerHand)
    elsif strat == :hit
      log "HITTING #{dps dealerHand,playerHand}"
      playerHand << @shoe.deal_card
      play_hand(dealerHand, playerHand, curr_bet_size)
    elsif strat == :stay
      log "STAY #{dps dealerHand, playerHand}"
      hand_result = finish_hand(dealerHand, playerHand)
    elsif strat == :surrender
      log "SURRENDER! #{dp dealerHand, playerHand}"
      @num_surrenders = @num_surrenders + 1
      @total_winnings -= curr_bet_size / 2.0
    else
      raise "Something's wrong #{dp dealerHand, playerHand}"
    end

    if (hand_result == :win)
      log "WIN! #{dp dealerHand, playerHand}"
      @num_wins = @num_wins + 1
      @total_winnings = @total_winnings + curr_bet_size
    elsif hand_result == :loss
      log "LOSS! #{dp dealerHand, playerHand}"
      @num_losses = @num_losses + 1
      @total_winnings = @total_winnings - curr_bet_size
    elsif hand_result == :push
      log "PUSH! #{dp dealerHand, playerHand}"
      @num_pushes = @num_pushes + 1
    end

    @highest_winnings = [@total_winnings, @highest_winnings].max
    @lowest_winnings = [@total_winnings, @lowest_winnings].min
  end

  def finish_hand dealerHand, playerHand
    #deal to dealer to hard 17
    until dealerHand.hand_value >= 17 # && !dealerHand.is_soft?
      dealerHand << @shoe.deal_card
    end

    if playerHand.hand_value > dealerHand.hand_value || dealerHand.hand_value > 21
      return :win
    elsif playerHand.hand_value == dealerHand.hand_value
      return :push
    else
      return :loss
    end
  end

end


b = BlackjackGame.new 100000, 5, 8

b.play_game

puts b.to_s
