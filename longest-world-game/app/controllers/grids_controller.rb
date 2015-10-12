require 'open-uri'
require 'json'
require 'time'


class GridsController < ApplicationController
  def game
    @grid = generate_grid(9).join(" ")
    @start_time = Time.now

  end

  def score
    @answer = params[:answer]
    @start_time = Time.parse(params[:start_time])
    @grid = params[:grid].split(' ')
    @end_time = Time.now
    @score = run_game(@answer, @grid, @start_time, @end_time)

  end

  def generate_grid(grid_size)
  letter_array = Array.new(grid_size) { ('A'..'Z').to_a.sample }
  return letter_array
  end

  def run_game(attempt, grid, start_time, end_time)
    api_url = "http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}"
    translation = nil
    run_game_hash = {}
    time_score = (end_time - start_time)
    run_game_hash[:time] = time_score
    unless in_the_grid?(attempt, grid)
      run_game_hash[:score] = 0
      run_game_hash[:message] = "not in the grid"
      return run_game_hash
    end
    open(api_url) { |stream| translation = JSON.parse(stream.read) }
    score = attempt.size * 2 - time_score
    run_game_hash[:score] = score
    if translation['term0'].nil?
      run_game_hash[:score] = 0
      run_game_hash[:message] = "not an english word"
    else
      run_game_hash[:translation] = translation['term0']['PrincipalTranslations']['0']['FirstTranslation']['term']
      run_game_hash[:message] = "well done"
    end
    return run_game_hash
  end

  def in_the_grid?(attempt, grid)
    intersection = attempt.upcase.split(//) & grid
    intersection.size == attempt.size
  end

end
