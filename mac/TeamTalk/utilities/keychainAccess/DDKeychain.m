/* 
 * Adium is the legal property of its developers, whose names are listed in the copyright file included
 * with this source distribution.
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
 * Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

/*!
 * @brief Cocoa wrapper for accessing the system keychain
 */

#import "DDKeychain.h"
#import "NSString+DDStringAdditions.h"

static DDKeychain *lastKnownDefaultKeychain = nil;

#define AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err) \
	NSLocalizedStringFromTableInBundle([[NSNumber numberWithLong:(err)] stringValue], @"SecErrorMessages", [NSBundle bundleWithIdentifier:@"com.apple.security"], /* comment */ nil)

@implementation DDKeychain

+ (BOOL)lockAllKeychains_error:(__strong NSError **)outError
{
	OSStatus err = SecKeychainLockAll();
	
	if (outError) {
		NSError *error = nil;
		
		if (err != noErr) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSValue valueWithPointer:SecKeychainLockAll], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
				@"SecKeychainLockAll", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
				AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
				nil];
			error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
		}
		
		*outError = error;
	}
	
	return (err == noErr);
}

+ (BOOL)lockDefaultKeychain_error:(__strong NSError **)outError
{
	OSStatus err = SecKeychainLock(/* keychain */ NULL);
	
	if (outError) {
		NSError *error = nil;
		
		if (err != noErr) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSValue valueWithPointer:SecKeychainLock], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
				@"SecKeychainLock", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
				AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
				nil];
			error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
		}
		
		*outError = error;
	}
	
	return (err == noErr);
}

+ (BOOL)unlockDefaultKeychain_error:(__strong NSError **)outError
{
	OSStatus err = SecKeychainUnlock(/* keychain */ NULL, /* passwordLength */ 0, /* password */ NULL, /* usePassword */ false);
	
	if (outError) {
		NSError *error = nil;
		
		if (err != noErr) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSValue valueWithPointer:SecKeychainUnlock], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
				@"SecKeychainUnlock", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
				AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
				nil];
			error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
		}
		
		*outError = error;
	}
	
	return (err == noErr);
}

+ (BOOL)unlockDefaultKeychainWithPassword:(NSString *)password error:(__strong NSError **)outError
{
	@autoreleasepool {

		NSData *data = [password dataUsingEncoding:NSUTF8StringEncoding];
		NSAssert( UINT_MAX >= [data length], @"Attempting to send more data than Keychain can handle.  Abort." );
		OSStatus err = SecKeychainUnlock(/* keychain */ NULL, (UInt32)[data length], [data bytes], /* usePassword */ true);

		if (outError) {
			NSError *error = nil;
			
			if (err != noErr) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					[NSValue valueWithPointer:SecKeychainUnlock], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
					@"SecKeychainUnlock", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
					AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
					nil];
				error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
			}
			
			*outError = error;
		}
		return (err == noErr);
	}
}

+ (BOOL)allowsUserInteraction_error:(__strong NSError **)outError
{
	Boolean state = false;

	OSStatus err = SecKeychainGetUserInteractionAllowed(&state);

	if (outError) {
		NSError *error = nil;

		if (err != noErr) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSValue valueWithPointer:SecKeychainGetUserInteractionAllowed], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
				@"SecKeychainGetUserInteractionAllowed", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
				AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
				nil];
			error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
		}
		
		*outError = error;
	}

	return state;
}

+ (BOOL)setAllowsUserInteraction:(BOOL)flag error:(__strong NSError **)outError
{
	OSStatus err = SecKeychainSetUserInteractionAllowed(flag);
	
	if (outError) {
		NSError *error = nil;
		
		if (err != noErr) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSValue valueWithPointer:SecKeychainSetUserInteractionAllowed], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
				@"SecKeychainSetUserInteractionAllowed", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
				AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
				[NSNumber numberWithBool:flag], AIKEYCHAIN_ERROR_USERINFO_USERINTERACTIONALLOWEDSTATE,
				nil];
			error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
		}
		
		*outError = error;
	}
	
	return (err == noErr);
}

+ (u_int32_t)keychainServicesVersion_error:(__strong NSError **)outError
{
	UInt32 version;
	// Will this function EVER return an error? well, it can, so we should be prepared for it. --boredzo
	OSStatus err = SecKeychainGetVersion(&version);
	
	if (outError) {
		NSError *error = nil;
		
		if (err != noErr) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSValue valueWithPointer:SecKeychainGetVersion], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
				@"SecKeychainGetVersion", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
				AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
				nil];
			error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
		}

		*outError = error;
	}

	return version;
}

#pragma mark -

+ (SecKeychainRef)copyDefaultSecKeychainRef_error:(__strong NSError **)outError
{
	SecKeychainRef aKeychainRef = NULL;

	OSStatus err = SecKeychainCopyDefault(&aKeychainRef);

	if (err != noErr) {
		if (err == errSecNoDefaultKeychain) {
			/* XXX - SecKeychainCreate() to an appropriate path here, followed by SecKeychainSetDefault(), would
			 * be very nice.  However, it really should not be necessary in general, since a default keychain is created
			 * at login. The only way we can get here is if the user deleted his default keychain during this OS X session
			 * and didn't create a new one.  He may not deserve password storage, anyways.
			 */
		}
		
		if (err != errSecNoDefaultKeychain) {
			if (outError) {
				NSError *error = nil;

				if (err != noErr) {
					NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
						[NSValue valueWithPointer:SecKeychainCopyDefault], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
						@"SecKeychainCopyDefault", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
						AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
						nil];
					error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
				}
				
				*outError = error;
			}
		}
		
		if (aKeychainRef) {
			CFRelease(aKeychainRef);
		}

		return nil;
	}
	
	return aKeychainRef;
}

+ (DDKeychain *)defaultKeychain_error:(__strong NSError **)outError
{
	// Ensure there is a default keychain which can be accessed
	SecKeychainRef aKeychainRef = [self copyDefaultSecKeychainRef_error:outError];
	
	if (aKeychainRef) {
		if (!lastKnownDefaultKeychain ||
			(aKeychainRef != [lastKnownDefaultKeychain keychainRef])) {
			lastKnownDefaultKeychain = [[self alloc] initWithKeychainRef:aKeychainRef];
		}

		CFRelease(aKeychainRef);

		return lastKnownDefaultKeychain;

	} else {
		DDLog(@"No default keychain!");
		return nil;
	}
}

+ (BOOL)setDefaultKeychain:(DDKeychain *)newDefaultKeychain error:(__strong NSError **)outError
{
	NSParameterAssert(newDefaultKeychain != nil);

	OSStatus err = ([newDefaultKeychain keychainRef] ? SecKeychainSetDefault([newDefaultKeychain keychainRef]) : noErr);
	
	if (outError) {
		NSError *error = nil;
		
		if (err != noErr) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSValue valueWithPointer:SecKeychainSetDefault], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
				@"SecKeychainSetDefault", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
				AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
				nil];
			error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
		}
		
		*outError = error;
	}
	
	if (err == noErr) {
		lastKnownDefaultKeychain = newDefaultKeychain;
	}
	
	return (err == noErr);
}

+ (DDKeychain *)keychainWithContentsOfFile:(NSString *)path error:(__strong NSError **)outError
{
	return [[self alloc] initWithContentsOfFile:path error:outError];
}

- (id)initWithContentsOfFile:(NSString *)path error:(__strong NSError **)outError
{
	if ((self = [super init])) {
		OSStatus err = SecKeychainOpen([path fileSystemRepresentation], &keychainRef);
		
		if (outError) {
			NSError *error = nil;

			if (err != noErr) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					[NSValue valueWithPointer:SecKeychainOpen], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
					@"SecKeychainOpen", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
					AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
					nil];
				error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
			}

			*outError = error;
		}
		
		if (err != noErr) {
			self = nil;
		}
	}

	return self;
}

// SecKeychainCreate

+ (DDKeychain *)keychainWithPath:(NSString *)path password:(NSString *)password promptUser:(BOOL)prompt initialAccess:(SecAccessRef)initialAccess error:(__strong NSError **)outError
{
	return [[self alloc] initWithPath:path password:password promptUser:prompt initialAccess:initialAccess error:outError];
}

- (id)initWithPath:(NSString *)path password:(NSString *)password promptUser:(BOOL)prompt initialAccess:(SecAccessRef)initialAccess error:(__strong NSError **)outError
{
	if ((self = [super init])) {
		/* We create our own copy of the string (if any) using NSString to ensure that the NSData that we create is an NSData.
		 * We create our own pool to ensure that both objects are released ASAP.
		 */
		@autoreleasepool {

			void     *passwordBytes  = NULL;
			u_int32_t passwordLength = 0;

			if (password) {
				NSData  *data = [password dataUsingEncoding:NSUTF8StringEncoding];
				passwordBytes      = (void *)[data bytes];
				NSAssert( UINT_MAX >= [data length], @"Attempting to send more data than Keychain can handle.  Abort." );
				passwordLength     = (UInt32)[data length];
			}

			OSStatus err = SecKeychainCreate([path fileSystemRepresentation], passwordLength, passwordBytes, prompt, initialAccess, &keychainRef);

			if (outError) {
				NSError *error = nil;
				if (err != noErr) {
					NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
						[NSValue valueWithPointer:SecKeychainCreate], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
						@"SecKeychainCreate", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
						AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
						nil];
					error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
				}

				*outError = error;
			}

			if (err != noErr) {
				self = nil;
			}
		}
	}

	return self;
}

+ (DDKeychain *)keychainWithKeychainRef:(SecKeychainRef)newKeychainRef
{
	return [[self alloc] initWithKeychainRef:newKeychainRef];
}

- (id)initWithKeychainRef:(SecKeychainRef)newKeychainRef
{
	if ((self = [super init])) {
		keychainRef = (newKeychainRef ? (SecKeychainRef)CFRetain(newKeychainRef) : NULL);
	}

	return self;
}

#pragma mark -

- (BOOL)getSettings:(out struct SecKeychainSettings *)outSettings error:(__strong NSError **)outError
{
	NSParameterAssert(outSettings != NULL);
	SecKeychainRef targetKeychainRef = (keychainRef ? (SecKeychainRef)CFRetain(keychainRef) : NULL);

	if (!targetKeychainRef) {
		targetKeychainRef = [[self class] copyDefaultSecKeychainRef_error:outError];
	}

	if (targetKeychainRef) {
		OSStatus err = SecKeychainCopySettings(targetKeychainRef, outSettings);
		
		if (outError) {
			NSError *error = nil;
			
			if (err != noErr) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					[NSValue valueWithPointer:outSettings], AIKEYCHAIN_ERROR_USERINFO_SETTINGSPOINTER,
					[NSValue valueWithPointer:SecKeychainCopySettings], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
					@"SecKeychainCopySettings", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
					AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
					nil];
				error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
			}

			*outError = error;
		}
		
		CFRelease(targetKeychainRef);
		
		return (err == noErr);
	}
	
	return NO;
}

- (BOOL)setSettings:(in struct SecKeychainSettings *)newSettings error:(__strong NSError **)outError
{
	NSParameterAssert(newSettings != NULL);
	// If keychainRef is NULL, we'll get the default keychain's settings
	OSStatus err = SecKeychainSetSettings(keychainRef, newSettings);
	
	if (outError) {
		NSError *error = nil;
		
		if (err != noErr) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSValue valueWithPointer:newSettings], AIKEYCHAIN_ERROR_USERINFO_SETTINGSPOINTER,
				[NSValue valueWithPointer:SecKeychainSetSettings], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
				@"SecKeychainSetSettings", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
				AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
				nil];
			error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
		}

		*outError = error;
	}
	
	return (err == noErr);
}

- (SecKeychainStatus)status_error:(__strong NSError **)outError
{
	SecKeychainStatus status;
	// If keychainRef is NULL, we'll get the default keychain's status
	OSStatus err = SecKeychainGetStatus(keychainRef, &status);
	
	if (outError) {
		NSError *error = nil;
		
		if (err != noErr) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSValue valueWithPointer:SecKeychainGetStatus], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
				@"SecKeychainGetStatus", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
				AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
				nil];
			error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
		}

		*outError = error;
	}

	return status;
}

- (char *)getPathFileSystemRepresentation:(out char *)outBuf length:(inout u_int32_t *)outLength error:(__strong NSError **)outError
{
	NSParameterAssert(outBuf != NULL);
	NSParameterAssert((outLength != NULL) && (*outLength > 0));

	SecKeychainRef targetKeychainRef = (keychainRef ? (SecKeychainRef)CFRetain(keychainRef) : NULL);
	
	if (!targetKeychainRef) {
		targetKeychainRef = [[self class] copyDefaultSecKeychainRef_error:outError];
	}

	if (targetKeychainRef) {		
		OSStatus err = SecKeychainGetPath(targetKeychainRef, (UInt32 *)outLength, outBuf);
		NSError *error = nil;
		
		if (err != noErr) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSValue valueWithPointer:SecKeychainGetPath], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
				@"SecKeychainGetPath", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
				AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
				[NSValue valueWithPointer:targetKeychainRef], AIKEYCHAIN_ERROR_USERINFO_KEYCHAIN,
				nil];
			
			if (outError) {
				error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
			}

			outBuf = NULL;
		}
		
		if (outError) {
			*outError = error;
		}

		CFRelease(targetKeychainRef);

	} else {
		outBuf = NULL;	
	}

	return outBuf;
}

- (NSString *)path
{
	NSMutableData *data = [NSMutableData dataWithLength:PATH_MAX];
	u_int32_t size = PATH_MAX;
	[self getPathFileSystemRepresentation:[data mutableBytes]
								   length:&size
									error:NULL];
	[data setLength:size];

	return [NSString stringWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark -

- (BOOL)lockKeychain_error:(__strong NSError **)outError
{
	// If keychainRef is NULL, the default keychain will locked
	OSStatus err = SecKeychainLock(keychainRef);
	
	if (outError) {
		NSError *error = nil;
		
		if (err != noErr) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSValue valueWithPointer:SecKeychainLock], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
				@"SecKeychainLock", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
				AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
				[NSValue valueWithPointer:keychainRef], AIKEYCHAIN_ERROR_USERINFO_KEYCHAIN,
				nil];
			error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
		}

		*outError = error;
	}
	
	return (err == noErr);
}

- (BOOL)unlockKeychain_error:(__strong NSError **)outError
{
	// If keychainRef is NULL, the default keychain will unlocked
	OSStatus err = SecKeychainUnlock(keychainRef, /* passwordLength */ 0, /* password */ NULL, /* usePassword */ false);
	
	if (outError) {
		NSError *error = nil;
		
		if (err != noErr) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSValue valueWithPointer:SecKeychainUnlock], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
				@"SecKeychainUnlock", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
				AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
				[NSValue valueWithPointer:keychainRef], AIKEYCHAIN_ERROR_USERINFO_KEYCHAIN,
				nil];
			error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
		}

		*outError = error;
	}

	return (err == noErr);
}

- (BOOL)unlockKeychainWithPassword:(NSString *)password error:(__strong NSError **)outError
{
	@autoreleasepool {

		NSData *data = [password dataUsingEncoding:NSUTF8StringEncoding];
		
		// If keychainRef is NULL, the default keychain will unlocked
		NSAssert( UINT_MAX >= [data length], @"Attempting to send more data than Keychain can handle.  Abort." );
		OSStatus err = SecKeychainUnlock(keychainRef, (UInt32)[data length], [data bytes], /* usePassword */ true);

		if (outError) {
			NSError *error = nil;
			
			if (err != noErr) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					[NSValue valueWithPointer:SecKeychainUnlock], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
					@"SecKeychainUnlock", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
					AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
					[NSValue valueWithPointer:keychainRef], AIKEYCHAIN_ERROR_USERINFO_KEYCHAIN,
					nil];
				error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
			}

			*outError = error;
		}

		return (err == noErr);
	}
}

#pragma mark -

- (BOOL)deleteKeychain_error:(__strong NSError **)outError
{
	SecKeychainRef targetKeychainRef = (keychainRef ? (SecKeychainRef)CFRetain(keychainRef) : NULL);
	
	if (!targetKeychainRef) {
		targetKeychainRef = [[self class] copyDefaultSecKeychainRef_error:outError];
	}
	
	if (targetKeychainRef) {				
		/* In 10.2, passing NULL to SecKeychainDelete deletes the default keychain
		 * In 10.3+, passing NULL returns errSecInvalidKeychain
		 */
		OSStatus err = SecKeychainDelete(targetKeychainRef);

		if (outError) {
			NSError *error = nil;
			if (err != noErr) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					[NSValue valueWithPointer:SecKeychainDelete], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
					@"SecKeychainDelete", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
					AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
					[NSValue valueWithPointer:targetKeychainRef], AIKEYCHAIN_ERROR_USERINFO_KEYCHAIN,
					nil];
				error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
			}

			*outError = error;
		}

		CFRelease(targetKeychainRef);
		
		return (err == noErr);
	}
	
	return NO;
}

#pragma mark -

- (BOOL)addInternetPassword:(NSString *)password
				  forServer:(NSString *)server
			 securityDomain:(NSString *)domain	// Can pass nil
					account:(NSString *)account
					   path:(NSString *)path
					   port:(u_int16_t)port		// Can pass 0
				   protocol:(SecProtocolType)protocol
		 authenticationType:(SecAuthenticationType)authType
			   keychainItem:(out SecKeychainItemRef *)outKeychainItem
					  error:(__strong NSError **)outError
{
	NSParameterAssert(password != nil);
	NSParameterAssert(server != nil);
	// Domain is optional

	@autoreleasepool {

		NSData   *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];

		NSData *serverData  = [server  dataUsingEncoding:NSUTF8StringEncoding];
		NSData *domainData  = [domain  dataUsingEncoding:NSUTF8StringEncoding];
		NSData *accountData = [account dataUsingEncoding:NSUTF8StringEncoding];
		NSData *pathData    = [path    dataUsingEncoding:NSUTF8StringEncoding];

		NSAssert( (UINT_MAX >= [passwordData length]) &&
						  (UINT_MAX >= [serverData length]) &&
						  (UINT_MAX >= [domainData length]) &&
						  (UINT_MAX >= [accountData length]) &&
						  (UINT_MAX >= [pathData length]),
						  @"Attempting to send more data than Keychain can handle.  Abort." );
		// If keychainRef is NNULL, the password will be added to the default keychain
		OSStatus err = SecKeychainAddInternetPassword(keychainRef,
													  (UInt32)[serverData length],  [serverData bytes],
													  // Domain is optional, so be sure to handle domain == nil
													  domainData ? (UInt32)[domainData length] : 0,
													  domainData ? [domainData bytes]  : NULL,
													  // Account appears optional, even though it isn't so documented
													  accountData ? (UInt32)[accountData length] : 0,
													  accountData ? [accountData bytes]  : NULL,
													  // Path appears optional, even though it isn't so documented
													  pathData ? (UInt32)[pathData length] : 0,
													  pathData ? [pathData bytes]  : NULL,
													  port,
													  protocol,
													  authType,
													  (UInt32)[passwordData length], [passwordData bytes],
													  outKeychainItem);

		if (outError) {
			NSError *error = nil;
			
			if (err != noErr) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					[NSValue valueWithPointer:SecKeychainAddInternetPassword], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
					@"SecKeychainAddInternetPassword", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
					AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
					server,  AIKEYCHAIN_ERROR_USERINFO_SERVER,
					domain,  AIKEYCHAIN_ERROR_USERINFO_DOMAIN,
					account, AIKEYCHAIN_ERROR_USERINFO_ACCOUNT,
					NSFileTypeForHFSTypeCode(protocol), AIKEYCHAIN_ERROR_USERINFO_PROTOCOL,
					NSFileTypeForHFSTypeCode(authType), AIKEYCHAIN_ERROR_USERINFO_AUTHENTICATIONTYPE,
					[NSValue valueWithPointer:keychainRef], AIKEYCHAIN_ERROR_USERINFO_KEYCHAIN,
					nil];
				error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
			}

			*outError = error;
		}

		return (err == noErr);
	}
}

- (BOOL)addInternetPassword:(NSString *)password forServer:(NSString *)server account:(NSString *)account protocol:(SecProtocolType)protocol error:(__strong NSError **)outError
{
	return [self addInternetPassword:password
						   forServer:server
					  securityDomain:nil
							 account:account
								path:nil
								port:0
							protocol:protocol
				  authenticationType:kSecAuthenticationTypeDefault
						keychainItem:NULL
							   error:outError];
}

#pragma mark -

- (NSString *)findInternetPasswordForServer:(NSString *)server
							 securityDomain:(NSString *)domain	// Can pass nil
									account:(NSString *)account
									   path:(NSString *)path
									   port:(u_int16_t)port		// Can pass 0
								   protocol:(SecProtocolType)protocol
						 authenticationType:(SecAuthenticationType)authType
							   keychainItem:(out SecKeychainItemRef *)outKeychainItem
									  error:(__strong NSError **)outError
{
	void  *passwordData   = NULL;
	UInt32 passwordLength = 0;

	NSData *serverData  = [server  dataUsingEncoding:NSUTF8StringEncoding];
	NSData *domainData  = [domain  dataUsingEncoding:NSUTF8StringEncoding];
	NSData *accountData = [account dataUsingEncoding:NSUTF8StringEncoding];
	NSData *pathData    = [path    dataUsingEncoding:NSUTF8StringEncoding];
	NSString *passwordString = nil;

	NSAssert( (UINT_MAX >= [serverData length]) &&
					  (UINT_MAX >= [domainData length]) &&
					  (UINT_MAX >= [accountData length]) &&
					  (UINT_MAX >= [pathData length]),
					  @"Attempting to send more data than Keychain can handle.  Abort." );
	// If keychainRef is NULL, the users's default keychain search list will be used
	OSStatus err = SecKeychainFindInternetPassword(keychainRef,
												   (UInt32)[serverData length],  [serverData bytes],
												   // Domain is optional, so be sure to handle domain == nil
												   domainData ? (UInt32)[domainData length] : 0,
												   domainData ? [domainData bytes]  : NULL,
												   // Account appears optional, even though it isn't so documented
												   accountData ? (UInt32)[accountData length] : 0,
												   accountData ? [accountData bytes]  : NULL,
												   // Path appears optional, even though it isn't so documented
												   pathData ? (UInt32)[pathData length] : 0,
												   pathData ? [pathData bytes]  : NULL,
												   port,
												   protocol,
												   authType,
												   &passwordLength,
												   &passwordData,
												   outKeychainItem);
	if (outError) {
		NSError *error = nil;
		
		if (err != noErr) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSValue valueWithPointer:SecKeychainFindInternetPassword], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
				@"SecKeychainFindInternetPassword", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
				AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
				server,  AIKEYCHAIN_ERROR_USERINFO_SERVER,
				domain,  AIKEYCHAIN_ERROR_USERINFO_DOMAIN,
				account, AIKEYCHAIN_ERROR_USERINFO_ACCOUNT,
				NSFileTypeForHFSTypeCode(protocol), AIKEYCHAIN_ERROR_USERINFO_PROTOCOL,
				NSFileTypeForHFSTypeCode(authType), AIKEYCHAIN_ERROR_USERINFO_AUTHENTICATIONTYPE,
				[NSValue valueWithPointer:keychainRef], AIKEYCHAIN_ERROR_USERINFO_KEYCHAIN,
				nil];
			error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
		}

		*outError = error;
	}

	passwordString = [NSString stringWithBytes:passwordData length:passwordLength encoding:NSUTF8StringEncoding];
	
	if (err == noErr) {
		SecKeychainItemFreeContent(NULL, passwordData);
	}
	
	return passwordString;
}

- (NSString *)internetPasswordForServer:(NSString *)server account:(NSString *)account protocol:(SecProtocolType)protocol error:(__strong NSError **)outError
{
	NSString *password = [self findInternetPasswordForServer:server
											  securityDomain:nil
													 account:account
														path:nil
														port:0
													protocol:protocol
										  authenticationType:kSecAuthenticationTypeDefault
												keychainItem:NULL
													   error:outError];

	return password;
}

- (NSDictionary *)dictionaryFromKeychainForServer:(NSString *)server protocol:(SecProtocolType)protocol error:(__strong NSError **)outError
{
	NSAssert( UINT_MAX >= [server length], @"Attempting to send more data than Keychain can handle.  Abort." );
	NSDictionary *result = nil;

	// Search for keychain items whose server is our key
	SecKeychainItemRef item = NULL;
	UInt32 passwordLength = 0U;
	void  *passwordBytes = NULL;
	
	// If keychainRef is NULL, the user's default keychain search list will be used
	OSStatus err = SecKeychainFindInternetPassword(keychainRef,
												   (unsigned int)[server length],
												   [server UTF8String],
												   0,
												   NULL,
												   0,
												   NULL,
												   0,
												   NULL,
												   0,
												   protocol,
												   kSecAuthenticationTypeAny,
												   &passwordLength,
												   &passwordBytes,
												   &item);
	
	if (err == errSecItemNotFound) {
		// No matching server found
	} else if (err == noErr) {
		// Output storage.
		struct SecKeychainAttributeList *attrList = NULL;

		// First, grab the username.
		UInt32    tags[] = { kSecAccountItemAttr };
		UInt32 formats[] = { CSSM_DB_ATTRIBUTE_FORMAT_STRING };
		struct SecKeychainAttributeInfo info = {
			.count  = 1,
			.tag    = tags,
			.format = formats,
		};
		SecKeychainItemFreeContent( NULL, passwordBytes );
		err = SecKeychainItemCopyAttributesAndData(item,
												   &info,
												   /* itemClass */ NULL,
												   &attrList,
												   &passwordLength,
												   &passwordBytes);
		if (err == noErr) {
			NSString *username = [NSString stringWithBytes:attrList->attr[0].data length:attrList->attr[0].length encoding:NSUTF8StringEncoding];
			NSString *password = [NSString stringWithBytes:passwordBytes length:passwordLength encoding:NSUTF8StringEncoding];
			result = [NSDictionary dictionaryWithObjectsAndKeys:
				username, @"Username",
				password, @"Password",
				nil];
			
			SecKeychainItemFreeAttributesAndData(attrList, passwordBytes);
		} else {
			DDLog(@"Error extracting infomation from keychain item");
		}

		if (item) {
			CFRelease(item);
		}
	} else {
		DDLog(@"%@: Could not create search; err is %ld", self, (long)err);
	}

	return result;
}

#pragma mark -

- (BOOL)setInternetPassword:(NSString *)password
				  forServer:(NSString *)server
			 securityDomain:(NSString *)domain	// Can pass nil
					account:(NSString *)account
					   path:(NSString *)path
					   port:(u_int16_t)port		// Can pass 0
				   protocol:(SecProtocolType)protocol
		 authenticationType:(SecAuthenticationType)authType
			   keychainItem:(out SecKeychainItemRef *)outKeychainItem
					  error:(__strong NSError **)outError
{
	BOOL success = NO;

	if (!password) {
		// Remove the password
		success = [self deleteInternetPasswordForServer:server
										 securityDomain:domain
												account:account
												   path:path
												   port:port
											   protocol:protocol
									 authenticationType:authType
										   keychainItem:outKeychainItem
												  error:outError];
	} else {
		// Add it if it does not exist
		NSError *error = nil;
		[self addInternetPassword:password
						forServer:server
				   securityDomain:domain
						  account:account
							 path:path
							 port:port
						 protocol:protocol
			   authenticationType:authType
					 keychainItem:outKeychainItem
							error:&error];
		if (error) {
			NSInteger err = [error code];

			if (err == errSecDuplicateItem) {
				/* We already have an item for this, so find it and change it
				 * We create an autorelease pool because of the string that -findInternetPasswordForServer:... returns
				 */

				SecKeychainItemRef item = NULL;
				@autoreleasepool {

					[self findInternetPasswordForServer:server
										 securityDomain:domain
												account:account
												   path:path
												   port:port
											   protocol:protocol
									 authenticationType:authType
										   keychainItem:&item
												  error:&error];

					if (error) {
						// Retain this because of the autorelease pool
						if (outError) {
							*outError = error;
						}
					} else {
						NSData   *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
						NSAssert( UINT_MAX >= [passwordData length], @"Attempting to send more data than Keychain can handle.  Abort." );

						// Change the password.
						err = SecKeychainItemModifyAttributesAndData(item,
																	 /* attrList */ NULL,
																	 (UInt32)[passwordData length],
																	 [passwordData bytes]);
						if (outError) {
							if (err == noErr) {
								error = nil;
							} else {
								NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSValue valueWithPointer:SecKeychainItemModifyAttributesAndData], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
									@"SecKeychainItemModifyAttributesAndData", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
									AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
									server,  AIKEYCHAIN_ERROR_USERINFO_SERVER,
									domain,  AIKEYCHAIN_ERROR_USERINFO_DOMAIN,
									account, AIKEYCHAIN_ERROR_USERINFO_ACCOUNT,
									NSFileTypeForHFSTypeCode(protocol), AIKEYCHAIN_ERROR_USERINFO_PROTOCOL,
									NSFileTypeForHFSTypeCode(authType), AIKEYCHAIN_ERROR_USERINFO_AUTHENTICATIONTYPE,
									[NSValue valueWithPointer:keychainRef], AIKEYCHAIN_ERROR_USERINFO_KEYCHAIN,
									nil];
								// Retain this because of the autorelease pool
								error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
							}
							*outError = error;
						} // if (outError)
					} // if (!error) (findInternetPasswordForServer:...)
				} // if (err == errSecDuplicateItem)
				
				success = (err == noErr);
			}
		} // if (error) (addInternetPassword:...)
	} // if (password)
	
	return success;
}

- (BOOL)setInternetPassword:(NSString *)password
				  forServer:(NSString *)server
					account:(NSString *)account
				   protocol:(SecProtocolType)protocol
					  error:(__strong NSError **)outError
{
	return [self setInternetPassword:password
						   forServer:server
					  securityDomain:nil
							 account:account
								path:nil
								port:0
							protocol:protocol
				  authenticationType:kSecAuthenticationTypeDefault
						keychainItem:NULL
							   error:outError];
}

#pragma mark -

- (BOOL)deleteInternetPasswordForServer:(NSString *)server
						 securityDomain:(NSString *)domain	// Can pass nil
								account:(NSString *)account
								   path:(NSString *)path
								   port:(u_int16_t)port		// Can pass 0
							   protocol:(SecProtocolType)protocol
					 authenticationType:(SecAuthenticationType)authType
						   keychainItem:(out SecKeychainItemRef *)outKeychainItem
								  error:(__strong NSError **)outError
{
	@autoreleasepool {
		
		SecKeychainItemRef keychainItem = NULL;
		NSError *error = nil;

		[self findInternetPasswordForServer:server
							 securityDomain:domain
									account:account
									   path:path
									   port:port
								   protocol:protocol
						 authenticationType:authType
							   keychainItem:&keychainItem
									  error:&error];

		BOOL success = NO;
		
		if (keychainItem) {
			OSStatus err = SecKeychainItemDelete(keychainItem);
			
			
			if (outError) {
				if (err == noErr) {
					error = nil;
				} else if (!error) {
					NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
						[NSValue valueWithPointer:SecKeychainFindInternetPassword], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
						@"SecKeychainFindInternetPassword", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
						AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
						server,  AIKEYCHAIN_ERROR_USERINFO_SERVER,
						account, AIKEYCHAIN_ERROR_USERINFO_ACCOUNT,
						NSFileTypeForHFSTypeCode(protocol), AIKEYCHAIN_ERROR_USERINFO_PROTOCOL,
						NSFileTypeForHFSTypeCode(kSecAuthenticationTypeDefault), AIKEYCHAIN_ERROR_USERINFO_AUTHENTICATIONTYPE,
						[NSValue valueWithPointer:keychainRef], AIKEYCHAIN_ERROR_USERINFO_KEYCHAIN,
						nil];
					error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
				}
			}
			
			success = (err == noErr);
		}

		if (outError) {
			*outError = error;
		}
		
		if (outKeychainItem) {
			*outKeychainItem = keychainItem;
		} else if (keychainItem) {
			CFRelease(keychainItem);
		}
		
		return success;
	}
}

- (BOOL)deleteInternetPasswordForServer:(NSString *)server account:(NSString *)account protocol:(SecProtocolType)protocol error:(__strong NSError **)outError
{
	return [self deleteInternetPasswordForServer:server
								  securityDomain:nil
										 account:account
											path:nil
											port:0
										protocol:protocol
							  authenticationType:kSecAuthenticationTypeDefault
									keychainItem:NULL
										   error:outError];
}

#pragma mark -

- (BOOL)addGenericPassword:(NSString *)password
				forService:(NSString *)service
				   account:(NSString *)account
			  keychainItem:(out SecKeychainItemRef *)outKeychainItem
					 error:(__strong NSError **)outError
{
	NSParameterAssert(password != nil);
	NSParameterAssert(service != nil);
	NSParameterAssert(account != nil);

	@autoreleasepool {

		NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
		NSData *serviceData = [service dataUsingEncoding:NSUTF8StringEncoding];
		NSData *accountData = [account dataUsingEncoding:NSUTF8StringEncoding];
		
		NSAssert( (UINT_MAX >= [passwordData length]) &&
						  (UINT_MAX >= [serviceData length]) &&
						  (UINT_MAX >= [accountData length]),
						  @"Attempting to send more data than Keychain can handle.  Abort." );
		// If keychainRef is NULL, the default keychain will be used
		OSStatus err = SecKeychainAddGenericPassword(keychainRef,
													  (UInt32)[serviceData length],  [serviceData bytes],
													  (UInt32)[accountData length],  [accountData bytes],
													 (UInt32)[passwordData length], [passwordData bytes],
													 outKeychainItem);

		if (outError) {
			NSError *error = nil;
			
			if (err != noErr) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					[NSValue valueWithPointer:SecKeychainAddGenericPassword], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
					@"SecKeychainAddGenericPassword", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
					AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
					service, AIKEYCHAIN_ERROR_USERINFO_SERVICE,
					account, AIKEYCHAIN_ERROR_USERINFO_ACCOUNT,
					[NSValue valueWithPointer:keychainRef], AIKEYCHAIN_ERROR_USERINFO_KEYCHAIN,
					nil];
				error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
			}

			*outError = error;
		}
		
		return (err == noErr);
	}
}

- (NSString *)findGenericPasswordForService:(NSString *)service
									account:(NSString *)account
							   keychainItem:(out SecKeychainItemRef *)outKeychainItem
									  error:(__strong NSError **)outError
{
	void  *passwordData   = NULL;
	UInt32 passwordLength = 0;

	NSData *serviceData = [service dataUsingEncoding:NSUTF8StringEncoding];
	NSData *accountData = [account dataUsingEncoding:NSUTF8StringEncoding];
	NSString *passwordString = nil;

	NSAssert( (UINT_MAX >= [serviceData length]) &&
					  (UINT_MAX >= [accountData length]),
					  @"Attempting to send more data than Keychain can handle.  Abort." );
	// If keychainRef is NULL, the users's default keychain search list will be used
	OSStatus err = SecKeychainFindGenericPassword(keychainRef,
												  (UInt32)[serviceData length],  [serviceData bytes],
												  (UInt32)[accountData length],  [accountData bytes],
												  &passwordLength,
												  &passwordData,
												  outKeychainItem);
	if (outError) {
		NSError *error = nil;
		
		if (err != noErr) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSValue valueWithPointer:SecKeychainFindGenericPassword], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
				@"SecKeychainFindGenericPassword", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
				AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
				service, AIKEYCHAIN_ERROR_USERINFO_SERVICE,
				account, AIKEYCHAIN_ERROR_USERINFO_ACCOUNT,
				[NSValue valueWithPointer:keychainRef], AIKEYCHAIN_ERROR_USERINFO_KEYCHAIN,
				nil];
			error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
		}

		*outError = error;
	}

	passwordString = [NSString stringWithBytes:passwordData length:passwordLength encoding:NSUTF8StringEncoding];

	if (err == noErr) {
		SecKeychainItemFreeContent(NULL, passwordData);
	}

	return passwordString;	
}

- (BOOL)deleteGenericPasswordForService:(NSString *)service
								account:(NSString *)account
								  error:(__strong NSError **)outError
{
	@autoreleasepool {
		
		SecKeychainItemRef keychainItem = NULL;
		NSError *error = nil;

		[self findGenericPasswordForService:service
									account:account
							   keychainItem:&keychainItem
									  error:&error];
		
		BOOL success = NO;
		
		if (keychainItem) {
			OSStatus err = SecKeychainItemDelete(keychainItem);

			if (outError) {
				if (err == noErr) {
					error = nil;
				} else if (!error) {
					NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
											  [NSValue valueWithPointer:SecKeychainFindGenericPassword], AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION,
											  @"SecKeychainFindGenerictPassword", AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME,
											  AI_LOCALIZED_SECURITY_ERROR_DESCRIPTION(err), AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION,
											  service,  AIKEYCHAIN_ERROR_USERINFO_SERVICE,
											  account, AIKEYCHAIN_ERROR_USERINFO_ACCOUNT,
											  NSFileTypeForHFSTypeCode(kSecAuthenticationTypeDefault), AIKEYCHAIN_ERROR_USERINFO_AUTHENTICATIONTYPE,
											  [NSValue valueWithPointer:keychainRef], AIKEYCHAIN_ERROR_USERINFO_KEYCHAIN,
											  nil];
					error = [NSError errorWithDomain:AIKEYCHAIN_ERROR_DOMAIN code:err userInfo:userInfo];
				}

				*outError = error;
			}
			
			success = (err == noErr);
		}
		
		if (keychainItem) {
			CFRelease(keychainItem);
		}
		
		return success;
	}
}

#pragma mark -

// Returns the Keychain Services object that backs this object.
- (SecKeychainRef)keychainRef
{
	return keychainRef;
}

#pragma mark -

- (NSString *)description
{
	return [NSString stringWithFormat:@"<AIKeychain %p (%@)>", self, keychainRef];
}

@end
