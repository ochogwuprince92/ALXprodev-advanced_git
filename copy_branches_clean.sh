#!/bin/bash

# Ask for old and new repo URLs
read -p "Enter OLD repo URL: " OLD_REPO
read -p "Enter YOUR NEW repo URL: " NEW_REPO

# Temporary folder
WORK_DIR=temp_repo
mkdir $WORK_DIR
cd $WORK_DIR

# Clone shallow copy
git clone --depth=1 --no-single-branch $OLD_REPO old_repo
cd old_repo

# Get list of all remote branches
branches=$(git branch -r | grep -v '\->' | sed 's/origin\///')

# Loop through branches
for branch in $branches; do
    echo "Processing branch: $branch"

    # Checkout branch
    git checkout $branch

    # Copy to a safe temp folder
    BRANCH_DIR="../../${branch}_copy"
    mkdir $BRANCH_DIR
    cp -r . $BRANCH_DIR

    # Go to copy folder
    cd $BRANCH_DIR

    # Remove old git history
    rm -rf .git

    # Init fresh repo for this branch
    git init
    git branch -M $branch
    git remote add origin $NEW_REPO
    git add .
    git commit -m "Initial commit for $branch"
    git push origin $branch

    # Back to old repo folder
    cd - >/dev/null
done

echo "✅ All branches copied to your repo with fresh history!"
