class Api::V1::WikiPostsController < ActionController::API
include ActionController::HttpAuthentication::Token::ControllerMethods
    #change the class from just  Api::V1::WikiPostsController < ApplicationController to Api::V1::WikiPostsController < ApplicationController:API
    #after including ActionController remove (skip_before_action :verify_authenticity_token) with out the include ADD THE LINE BRACKET and remove before action
    require 'csv'
    before_action :authenticate  

    TOKEN =ENV["WIKI_API_KEY"]

    def index 
        #we will send  a query string paramseter eg localhost:3000/api/v1/wiki_posts/show?id=5&limit=9&page=10
        page = params[:page].to_i
        limit = params[:limit].to_i
        offset =(page-1) #refets to how many wiki_posts should be skipped before starting to return
        @wiki_posts = WikiPost.all.limit(limit).offset(offset) # .limit(),.offset() is an active record method that  will apply our offset and return the right elemetns
        render json: @wiki_posts 
    end 

    def show 
        begin 
            @wiki_post = WikiPost.find(params[:id])
        rescue 
            return render json: {"message": "Post not found"}
        end
        serialized =WikiPostSerializer.serialize(@wiki_post)
        render json: serialized
    end 

    def create 
        @wiki_post = WikiPost.new(wiki_post_params)
        if @wiki_post.save 
            render json: @wiki_post, status: :created
        else 
            render  json: @wiki_post.errors, status: :unprocessable_entity 
        end
    end 

    def xml_index 
        @wiki_posts =WikiPost.all 
        render xml: @wiki_posts 
    end 

    def csv_index 
        @wiki_posts = WikiPost.all 
        csv_data = CSV.generate do |csv|
            csv << ["ID", "Name", "Description"]
            @wiki_posts.each do |post|
                csv << [post.id,post.name,post.description]
            end 
        end 
        send_data csv_data, filename: "wiki_posts.csv",type: "text/csv"
    end 


    def update 
        @wiki_post =WikiPost.find(params[:id])
        
        if @wiki_post.update(wiki_post_params)
            render json: @wiki_post 
        else 
            render json: @wiki_post
        end 
    end 

    def destroy 

        @wiki_post = WikiPost.find(params[:id])
        @wiki_post.destroy 
        head :no_content 

    end

private
    def wiki_post_params 
        params.permit(:name,:description)
    end 
    #without include Action mailer remove this line
    def authenticate 
        authenticate_or_request_with_http_token do |token, options|
            ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
        end 
    end
end
