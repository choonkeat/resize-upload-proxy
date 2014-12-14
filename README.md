# Directly upload to S3 with image resized

**Option 1**: Get [jQuery-File-Upload client side resizing](https://github.com/blueimp/jQuery-File-Upload/wiki/Client-side-Image-Resizing) to work in your app. Good luck.

**Option 2**: Use [Amazon Lambda](http://aws.amazon.com/lambda/) - but Lambda activates *after* your fileupload, so there's an awkward, cache-unfriendly, in-between moment where the image is not resized yet, and you're unsure what you want to do with your hands.

**Option 3**: Use [refile](https://github.com/elabs/refile). Best, but beware of huge changes.

**Option 4**

1. Deploy this app to Heroku as-is, e.g. `https://resize-upload-proxy.example.com/`
2. Instead of pointing your [Amazon S3 Direct Upload](https://aws.amazon.com/articles/1434) to your S3 bucket URL, point to `https://resize-upload-proxy.example.com/?url=YOUR_BUCKET_URL&style=300x300%23` instead
3. There's no step 3

### What's happening:

When the upload (the file, the `signature`, the `policy`, etc) reaches this Rack app, the file will be resized based on `params[:style]` (see [Paperclip docs](https://github.com/thoughtbot/paperclip/wiki/Thumbnail-Generation#resizing-options)) and submitted to your bucket url specified in `params[:url]`.

When the image reach S3, it will already be resized in the desired dimensions.

Also, the response from S3 will be relayed back uploader - so any existing code that works with [Amazon S3 Direct Upload](https://aws.amazon.com/articles/1434) will continue to work transparently.

CORS headers that you've meticulously set in AWS Console will be proxied transparently.
