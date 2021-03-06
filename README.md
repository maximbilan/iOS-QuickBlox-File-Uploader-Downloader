<h2>Quickblox: Uploading from a file, downloading to a file</h2>

Unfortunately <a href="http://quickblox.com">QuickBlox iOS SDK</a> has methods for downloading and uploading only using memory. We need pass the <i>NSData</i> or receive <i>NSData</i>. It’s really problem. You can see methods from <a href="http://quickblox.com">QuickBlox iOS SDK</a> in the end of the article or <a href="http://sdk.quickblox.com/ios/">here</a>. In this sample I provide example, how to upload content from file, and how to download to file following the <a href="http://quickblox.com/developers/Content">API</a>.

<h3>Uploading</h3>

First of all we should create <i>QB File</i>. <a href="http://curl.haxx.se">Curl</a> request:
<pre>
curl -X POST \
-H "Content-Type: application/json" \
-H "QuickBlox-REST-API-Version: 0.1.0" \
-H "QB-Token: 20e55d804b6bff1cba87cb0215d8967150722ecb" \
-d '{"blob": {"content_type": "image/jpeg", "name": "museum.jpeg"}}' \
http://api.quickblox.com/blobs.json
</pre>

Response:

<pre>
{
  "blob": {
    "blob_status": null,
    "content_type": "image/jpeg",
    "created_at": "2012-04-23T13:22:34Z",
    "id": 315,
    "last_read_access_ts": null,
    "lifetime": 0,
    "name": "111.jpg",
    "public": false,
    "ref_count": 1,
    "set_completed_at": null,
    "size": null,
    "uid": "30a8bcd7c714417eb62b95350d7e13b900",
    "updated_at": "2012-04-23T13:22:34Z",
    "blob_object_access": {
      "blob_id": 315,
      "expires": "2012-04-23T14:22:34Z",
      "id": 315,
      "object_access_type": "Write",
      "params": "https://qbprod.s3.amazonaws.com/?Content-Type=image%2Fpng&Expires=Wed%2C%2030%20Sep%202015%2013%3A25%3A11%20GMT&acl=authenticated-read&key=fbc2d08125e3435ca5cb37f926d5fe8800&policy=eyJleHBpcmF0aW9uIjoiMjAxNS0wOS0zMFQxMzoyNToxMVoiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJxYnByb2QifSx7ImFjbCI6ImF1dGhlbnRpY2F0ZWQtcmVhZCJ9LHsiQ29udGVudC1UeXBlIjoiaW1hZ2UvcG5nIn0seyJzdWNjZXNzX2FjdGlvbl9zdGF0dXMiOiIyMDEifSx7IkV4cGlyZXMiOiJXZWQsIDMwIFNlcCAyMDE1IDEzOjI1OjExIEdNVCJ9LHsia2V5IjoiZmJjMmQwODEyNWUzNDM1Y2E1Y2IzN2Y5MjZkNWZlODgwMCJ9LHsieC1hbXotY3JlZGVudGlhbCI6IkFLSUFJWTdLRk0yM1hHWEo3UjdBLzIwMTUwOTMwL3VzLWVhc3QtMS9zMy9hd3M0X3JlcXVlc3QifSx7IngtYW16LWFsZ29yaXRobSI6IkFXUzQtSE1BQy1TSEEyNTYifSx7IngtYW16LWRhdGUiOiIyMDE1MDkzMFQxMjI1MTFaIn1dfQ%3D%3D&success_action_status=201&x-amz-algorithm=AWS4-HMAC-SHA256&x-amz-credential=AKIAIY7KFM23XGXJ7R7A%2F20150930%2Fus-east-1%2Fs3%2Faws4_request&x-amz-date=20150930T122511Z&x-amz-signature=a5c720c1a3b9b5c0b2549e0220419493ca3b11ce84618f6ece88ad97a96a8ad9"
    }
  }
}
</pre>

<i>Objective C</i> implementation:
<pre>
QBCBlob *b = [QBCBlob blob];
b.name = filename;
b.contentType = @"image/jpeg";
[QBRequest createBlob:b successBlock:^(QBResponse *response, QBCBlob *blob) {

} errorBlock:^(QBResponse *response) {

}];
</pre>

Now we have an amazon link, and we can upload the file. We need to do the following request:

<pre>
curl -X POST 
  -F "Content-Type=image/jpeg" 
  -F "Expires=Wed, 30 Sep 2015 13:29:39 GMT" 
  -F "acl=authenticated-read" 
  -F "key=76101edd87fe4b299ff41f63633bf9c100" 
  -F "policy=eyJleHBpcmF0aW9uIjoiMjAxNS0wOS0zMFQxMzoyOTozOVoiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJxYnByb2QifSx7ImFjbCI6ImF1dGhlbnRpY2F0ZWQtcmVhZCJ9LHsiQ29udGVudC1UeXBlIjoiaW1hZ2UvanBnIn0seyJzdWNjZXNzX2FjdGlvbl9zdGF0dXMiOiIyMDEifSx7IkV4cGlyZXMiOiJXZWQsIDMwIFNlcCAyMDE1IDEzOjI5OjM5IEdNVCJ9LHsia2V5IjoiNzYxMDFlZGQ4N2ZlNGIyOTlmZjQxZjYzNjMzYmY5YzEwMCJ9LHsieC1hbXotY3JlZGVudGlhbCI6IkFLSUFJWTdLRk0yM1hHWEo3UjdBLzIwMTUwOTMwL3VzLWVhc3QtMS9zMy9hd3M0X3JlcXVlc3QifSx7IngtYW16LWFsZ29yaXRobSI6IkFXUzQtSE1BQy1TSEEyNTYifSx7IngtYW16LWRhdGUiOiIyMDE1MDkzMFQxMjI5MzlaIn1dfQ==" 
  -F "success_action_status=201" 
  -F "x-amz-algorithm=AWS4-HMAC-SHA256" 
  -F "x-amz-credential=AKIAIY7KFM23XGXJ7R7A/20150930/us-east-1/s3/aws4_request" 
  -F "x-amz-date=20150930T122939Z" 
  -F "x-amz-signature=eee18ae3d47a745bccc9007d1b7b1679e855becb44b1928bb710428e18e397a8" 
  -F "file=@user_new_avatar.jpg"  
https://qbprod.s3.amazonaws.com/
</pre>

<a href="http://curl.haxx.se">Curl</a> response:

<pre>
&#60;PostResponse&#62;
  &#60;Location&#62;
    https://blobs-test-oz.s3.amazonaws.com/d5f92bcf84374e4fb8961537f7a7de6500
  &#60;/Location&#62;
  &#60;Bucket>blobs-test-oz&#60;/Bucket&#62;
  &#60;Key>d5f92bcf84374e4fb8961537f7a7de6500&#60;/Key&#62;
  &#60;ETag>"de1aae3e6beadb83bc8e1e21eb7e2a66"&#60;/ETag&#62;
&#60;/PostResponse&#62;
</pre>

In <i>Objective C</i> it’s more difficult. We need to do <i>Form Data</i> request. The easiest way to do this, use <a href="https://github.com/pokeb/asi-http-request">ASIHTTPRequest</a> framework. For example:

<pre>
NSDictionary *params = blob.blobObjectAccess.params;
ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:blob.blobObjectAccess.url];
[request setPostValue:params[@"Content-Type"] forKey:@"Content-Type"];
[request setPostValue:params[@"Expires"] forKey:@"Expires"];
[request setPostValue:params[@"acl"] forKey:@"acl"];
[request setPostValue:params[@"key"] forKey:@"key"];
[request setPostValue:params[@"policy"] forKey:@"policy"];
[request setPostValue:params[@"success_action_status"] forKey:@"success_action_status"];
[request setPostValue:params[@"x-amz-algorithm"] forKey:@"x-amz-algorithm"];
[request setPostValue:params[@"x-amz-credential"] forKey:@"x-amz-credential"];
[request setPostValue:params[@"x-amz-date"] forKey:@"x-amz-date"];
[request setPostValue:params[@"x-amz-signature"] forKey:@"x-amz-signature"];
[request setFile:url forKey:@"file"];

[request setCompletionBlock^{
}];

[request setFailedBlock:^{
}];

[request startAsynchronous];
</pre>

And after that we should set the file status to ‘<i>Complete</i>’. If the specified file size does not match to the actual, the actual will be set.

<a href="http://curl.haxx.se">Curl</a> request:

<pre>
curl -X PUT \
-H "Content-Type: application/json" \
-H "QuickBlox-REST-API-Version: 0.1.0" \
-H "QB-Token: 74b0087b00d748f944429f1c355b91169f5d9d52" \
-d '{"blob": {"size": "86"}}' \
http://api.quickblox.com/blobs/97/complete.json
</pre>

<i>Objective C</i>:

<pre>
NSError *attributesError;
NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:url error:&attributesError];
NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
NSUInteger fileSize = [fileSizeNumber unsignedIntegerValue];

[QBRequest completeBlobWithID:blob.ID size:fileSize successBlock:^(QBResponse *response) {

} errorBlock:^(QBResponse *response) {

}];
</pre>

That’s all about uploading.

<h3>Downloading</h3>

It’s easiest than uploading. One request for receiving url.

<a href="http://curl.haxx.se">Curl</a> request:

<pre>
curl -X POST \
-H "Content-Type: application/json" \
-H "QuickBlox-REST-API-Version: 0.1.0" \
-H "QB-Token: 74b0087b00d748f944429f1c355b91169f5d9d52" \
http://api.quickblox.com/blobs/301/getblobobjectbyid.json
</pre>

Response:

<pre>
{
  "blob_object_access": {
    "id": 97,
    "blob_id": 97,
    "expires": "2012-03-22T17:35:43Z",
    "object_access_type": "Read",
    "params": "https://blobs-test-oz.s3.amazonaws.com:443/49d386c6cc68437a9fcae66ce7edfa8b00?Signature=ZRKS05Fvlu5n8Cx2yTh7JQAZr7k%3D&Expires=1332437743&AWSAccessKeyId=AKIAJHMRS6ZUIQ6VTQDQ"
  }
}
</pre>

<i>Objective C</i>:

<pre>
[QBRequest blobObjectAccessWithBlobID:fileId successBlock:^(QBResponse *response, QBCBlobObjectAccess objectAccess) {

} errorBlock:^(QBResponse *response) {

}];
</pre>

For a simple way to download a file using <a href="https://github.com/maximbilan/MBFileDownloader">MBFileDownloader</a>:

<pre>
MBFileDownloader *fileDownloader = [[MBFileDownloader alloc] initWithURL:[NSURL URLWithString:objectAccess.urlWithParams] toFilePath:filePath];

[fileDownloader downloadWithSuccess:^{

} update:^(float value) {

} failure:^(NSError *error) {

}];
</pre>

That’s all.

<b>I provide a sample in this repository, the full process of uploading and downloading. Please use for free.</b>

<h3>Methods from QuickBlox iOS SDK</h3>
<pre>
#pragma mark -
#pragma mark Upload file using BlobObjectAccess

/**
 Upload file using BlobObjectAccess
 
 @param data File
 @param blobWithWriteAccess An instance of QBCBlobObjectAccess
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
&#43; (QBRequest *)uploadFile:(NSData *)data
      blobWithWriteAccess:(QBCBlob *)blobWithWriteAccess
             successBlock:(void(^)(QBResponse *response))successBlock
              statusBlock:(QBRequestStatusUpdateBlock)statusBlock
               errorBlock:(void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Download file

/**
 Download file
 
 @param UID File unique identifier, value of UID property of the QBCBlob instance.
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
&#43; (QBRequest *)downloadFileWithUID:(NSString *)UID
                      successBlock:(void(^)(QBResponse *response, NSData *fileData))successBlock
                       statusBlock:(QBRequestStatusUpdateBlock)statusBlock
                        errorBlock:(void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Tasks

/**
 Upload File task. Contains 3 requests: Create Blob, upload file, declaring file uploaded
 
 @param data file to be uploaded
 @param fileName name of the file
 @param contentType type of the content in mime format
 @param isPublic blob's visibility
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
 &#43; (QBRequest *)TUploadFile:(NSData*)data
                  fileName:(NSString*)fileName
               contentType:(NSString*)contentType
                  isPublic:(BOOL)isPublic
              successBlock:(void(^)(QBResponse *response, QBCBlob* blob))successBlock
               statusBlock:(QBRequestStatusUpdateBlock)statusBlock
                errorBlock:(void(^)(QBResponse *response))errorBlock;

/**
 Download File task. Contains 2 requests: Get Blob with ID, download file

 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param successBlock Block with response and fileData if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */

&#43; (QBRequest *)TDownloadFileWithBlobID:(NSUInteger)blobID
                          successBlock:(void(^)(QBResponse *response, NSData *fileData))successBlock
                           statusBlock:(QBRequestStatusUpdateBlock)statusBlock
                            errorBlock:(void(^)(QBResponse *response))errorBlock;
</pre>
