# File-Share system
Basic File-Share system, let users upload files and share them with others.

## Pre-requisites
1. AWS user with `AmazonS3FullAccess` policy.
2. AWS S3 bucket. One for public bucket one for private bucket.
3. AWS cloudfront distribution for the buckets.

## Installation
1. Setup the environment variables in the `.env` file by copying the `.env.example` file.
2. Run docker compose `docker-compose up -d --build`

## Architecture
[notion link](https://www.notion.so/System-Design-0a31e4d0f8ea4d8281030e81c2b7cd14)
