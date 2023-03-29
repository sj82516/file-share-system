# File-Share system
Basic File-Share system, let users upload files and share them with others.

## Pre-requisites
1. AWS user with `AmazonS3FullAccess` policy.
2. AWS S3 bucket. One for public bucket one for private bucket.
3. AWS cloudfront distribution for the buckets.
4. For local development, you need to install `docker`.

## Execution 
1. Setup the environment variables in the `.env` file by copying the `.env.example` file.
2. Run docker compose `docker-compose up -d --build`

## Architecture
[notion link](https://circular-carpet-0f1.notion.site/PicCollage-956bd5c5b31a4775aafab2384e09579e)

## How to run test
1. Run `docker compose up -d mysql`
2. Run rspec
