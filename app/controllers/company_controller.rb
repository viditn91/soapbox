class CompanyController < ApplicationController
  before_filter :set_company, only: [:show]

  def show
    if !(current_user)
      respond_to do |format|
        format.html { redirect_to new_user_session_path }
      end
    end
  end

  protected

  def set_company
    if(current_user && current_user.company)
      @company = current_user.company
    else
      redirect_to new_user_session_path
    end
  end

end