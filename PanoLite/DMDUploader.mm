//
//  DMDUploader.m
//  Twit360
//
//  Created by Elias Khoury on 5/10/13.
//  Copyright (c) 2013 Dermandar (Offshore) S.A.L. All rights reserved.
//

#import "DMDUploader.h"
#import "AFNetworking/AFNetworking.h"

@implementation DMDUploader

+ (NSURLRequest*)URLRequestForPanoramaPath:(NSString*)panoPath
{
	AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://www.dermandar.com"]];
	
	NSURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"/php/upload.php?iOS=1" parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
		
		//uploads panorama data
		NSURL *datatxt = [NSURL fileURLWithPath:[panoPath stringByAppendingPathComponent:@"data.txt"]];
		[formData appendPartWithFileURL:datatxt name:@"data" fileName:@"data.txt" mimeType:@"text/plain" error:NULL];
		
		//getting the number of images this panorama has
		int nb;
		char tmp[200];
		sprintf(tmp,"%s/data.txt",[panoPath UTF8String]);
		FILE *in=fopen(tmp,"r");
		fscanf(in,"%s%d",tmp,&nb);
		fclose(in);
		
		//addind the images to the request
		for (int i=0 ; i<nb ; ++i)
		{
			NSString *imname = [NSString stringWithFormat:@"%d",i];
			NSString *fpath = [panoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"00%02d+0.jpeg",i]];
			[formData appendPartWithFileURL:[NSURL fileURLWithPath:fpath] name:@"uploaded_file[]" fileName:imname mimeType:@"image/jpeg" error:NULL];
		}
		
		//additional request parameters you can set
		NSDictionary *details = [NSDictionary dictionaryWithContentsOfFile:[panoPath stringByAppendingPathComponent:@"details.plist"]];

		//required
		[formData appendPartWithFormData:[@"27nn77n5nn9qr0r48r8p6qq8q2so9074p4740o0r" dataUsingEncoding:NSUTF8StringEncoding] name:@"api_key"];
		NSString *name = [details objectForKey:@"name"];
		if (!name) name = @"Untitled";
		[formData appendPartWithFormData:[name dataUsingEncoding:NSUTF8StringEncoding] name:@"pano"];
		//required but can be empty strings
		[formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding] name:@"tags"];
		NSString *desc = [details objectForKey:@"description"];
		if (!desc) desc = @"";
		[formData appendPartWithFormData:[desc dataUsingEncoding:NSUTF8StringEncoding] name:@"description"];
		//don't change
		[formData appendPartWithFormData:[@"1" dataUsingEncoding:NSUTF8StringEncoding] name:@"pub"];
		
		//optional
		 //latitude
		if ([details objectForKey:@"latitude"])
			[formData appendPartWithFormData:[((NSNumber*)[details objectForKey:@"latitude"]).stringValue dataUsingEncoding:NSUTF8StringEncoding] name:@"lat"];
		 //longitude
		if ([details objectForKey:@"longitude"])
			[formData appendPartWithFormData:[((NSNumber*)[details objectForKey:@"longitude"]).stringValue dataUsingEncoding:NSUTF8StringEncoding] name:@"lon"];
		 //altitude
		if ([details objectForKey:@"altitude"])
			[formData appendPartWithFormData:[((NSNumber*)[details objectForKey:@"altitude"]).stringValue dataUsingEncoding:NSUTF8StringEncoding] name:@"altitude"];
		 //direction
		if ([details objectForKey:@"heading"])
			[formData appendPartWithFormData:[((NSNumber*)[details objectForKey:@"heading"]).stringValue dataUsingEncoding:NSUTF8StringEncoding] name:@"direction"];
		 //creation time
		 [formData appendPartWithFormData:[[details objectForKey:@"ctime"] dataUsingEncoding:NSUTF8StringEncoding] name:@"ctime"];
	}];
	
	return request;
}

@end
