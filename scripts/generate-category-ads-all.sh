jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Iran-v2ray-rules repository
        uses: actions/checkout@v4

      - name: Checkout category-ads-all list
        uses: actions/checkout@v4
        with:
          repository: v2fly/domain-list-community
          path: v2ray-geosite

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y dos2unix parallel

      - name: Generate category-ads-all domains list
        run: |
          chmod +x ./scripts/generate-category-ads-all.sh
          ./scripts/generate-category-ads-all.sh
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Optimize processing with parallel (if needed)
        run: |
          parallel -j 4 ./scripts/generate-category-ads-all.sh ::: $(cat ./v2ray-geosite/data/category-ads-all.txt)

      - name: Generate sha256sum
        run: |
          sha256sum release/category-ads-all.txt > release/category-ads-all.txt.sha256sum

      - name: Release and upload assets
        uses: softprops/action-gh-release@v2
        with:
          name: ${{ env.RELEASE_NAME }}
          tag_name: ${{ env.TAG_NAME }}
          body_path: RELEASE_NOTES
          files: |
            release/category-ads-all.txt
            release/category-ads-all.txt.sha256sum
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
