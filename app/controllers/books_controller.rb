class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def show
    @book = Book.find(params[:id])
    unless ViewCount.find_by(user_id: current_user.id, book_id: @book.id)
      current_user.view_counts.create(book_id: @book.id)
    end
    @book_comment = BookComment.new
  end

  def index
    to  = Time.current.at_beginning_of_day
    from  = (to - 6.day).at_end_of_day
    @books = Book.includes(:favorited_users).
      sort {|a,b| 
        b.favorited_users.includes(:favorites).where(created_at: from...to).size <=> 
        a.favorited_users.includes(:favorites).where(created_at: from...to).size
      }
    @book = Book.new
    @today_books_count = Book.where(created_at: Time.zone.now.all_day).count
    @one_books_count = Book.where(created_at: 1.day.ago).count
    @two_books_count = Book.where(created_at: 2.day.ago).count
    @three_books_count = Book.where(created_at: 3.day.ago).count
    @four_books_count = Book.where(created_at: 4.day.ago).count
    @five_books_count = Book.where(created_at: 5.day.ago).count
    @six_books_count = Book.where(created_at: 6.day.ago).count
    
    
    @cumulative = [@six_books_count,@five_books_count,@four_books_count,@three_books_count,@two_books_count,@one_books_count,@today_books_count]
    

 
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      @books = Book.all
      render 'index'
    end
  end

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to book_path(@book), notice: "You have updated book successfully."
    else
      render "edit"
    end
  end

  def destroy
    @book.destroy
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title, :body)
  end

  def ensure_correct_user
    @book = Book.find(params[:id])
    unless @book.user == current_user
      redirect_to books_path
    end
  end
end
