class MatchesController < ApplicationController
  before_action :set_match, only: [:show, :edit, :update, :destroy]

  # GET /matches
  # GET /matches.json
  def index
    if params[:matches_for_team]
      team = Team.find params[:matches_for_team]
      @matches = team.get_matches(params[:needs_action])
    else
      @matches = Match.all
    end

    render json: @matches
  end

  # GET /matches/1
  # GET /matches/1.json
  def show
    @match = Team.find(params[:id])
    render json: @match
  end

  # GET /matches/new
  def new
    @match = Match.new
  end

  # GET /matches/1/edit
  def edit
  end

  # POST /matches
  # POST /matches.json
  def create
    @match = Match.new(match_params)

    respond_to do |format|
      if @match.save
        format.html { redirect_to @match, notice: 'Match was successfully created.' }
        format.json { render json: @match, status: :created  }
      else
        format.html { render action: 'new' }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  def calculate_rating
    if @match.team_one_score > @match.team_two_score
      score = 1
    else
      score = 0
    end

    score_difference = @match.team_two.rating - @match.team_one.rating
    team_one_rating = score -  1.0 / ( (10**(score_difference/400.0))+1)
    team_one_rating *= 20

    score = score == 1 ? 0 : 1

    score_difference = @match.team_one.rating - @match.team_two.rating
    team_two_rating = score -  1.0 / ( (10**(score_difference/400.0) ) + 1 )
    team_two_rating *= 20
    
    @match.team_two.rating += team_two_rating
    @match.team_two.save!
    
    @match.team_one.rating += team_one_rating
    @match.team_one.save!
  end

  # PATCH/PUT /matches/1
  # PATCH/PUT /matches/1.json
  def update
    respond_to do |format|
      mp = match_params
      if @match.update(mp)
        format.json { render json: @match }
        calculate_rating
      else
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /matches/1
  # DELETE /matches/1.json
  def destroy
    @match.destroy
    respond_to do |format|
      format.html { redirect_to matches_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_match
      @match = Match.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def match_params
      params.require(:match).permit(:team_one_id, :team_two_id, :team_one_score, :team_two_score, :team_one_accepted_results, :team_two_accepted_results)
    end
end
