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

#import <Security/Security.h>

#pragma mark DDKeychain errors

/*!	@defgroup AIKeychainErrors AIKeychain errors
 *
 *	@par
 *	All \c AIKeychain methods return by reference an \c NSError object when the
 *	Keychain Services function that backs that method returns an \c OSStatus
 *	other than \c noErr.
 *
 *	The domain of the error is \c AIKEYCHAIN_ERROR_DOMAIN, and the error code is the \c OSStatus returned by Keychain Services.
 *
 *	You may pass \c NULL for the \a error argument, in which case the error will be
 *	silently dropped.
 */

/*@{*/

/*!	@def AIKEYCHAIN_ERROR_DOMAIN
 *	@brief The domain of all \c AIKeychain errors.
 *	Whenever you receive an \c NSError from an \c AIKeychain method, its domain will be \c AIKEYCHAIN_ERROR_DOMAIN.
 */
#define AIKEYCHAIN_ERROR_DOMAIN @"AIKeychainError"

/*!	@def AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION
 *	@brief The Keychain Services function that returned the error.
 *	This value is stored as an \c NSValue. Call \c -pointerValue to retrieve the function pointer.
 */
#define AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTION @"SecurityFrameworkFunction"

//!	@brief The name of the Keychain Services function that returned the error.
#define AIKEYCHAIN_ERROR_USERINFO_SECURITYFUNCTIONNAME @"SecurityFrameworkFunctionName"

//!	@brief Description of the error (from SecErrorMessages.strings).
#define AIKEYCHAIN_ERROR_USERINFO_ERRORDESCRIPTION @"SecurityFrameworkErrorDescription"

//!	@brief The \c AIKeychain instance that was involved.
#define AIKEYCHAIN_ERROR_USERINFO_KEYCHAIN @"Keychain"

/*!	@def AIKEYCHAIN_ERROR_USERINFO_USERINTERACTIONALLOWEDSTATE
 *	@brief The value that would have been returned by \c +allowsUserInteraction or was passed to <code>+setAllowsUserInteraction:</code>.
 *	This is an \c NSNumber containing a \c BOOL.
 */
#define AIKEYCHAIN_ERROR_USERINFO_USERINTERACTIONALLOWEDSTATE @"UserInteractionAllowed"

/*!	@def AIKEYCHAIN_ERROR_USERINFO_SETTINGSPOINTER
 *	@brief The pointer passed to <code>-getSettings:</code> or <code>-setSettings:</code>.
 *	This value is stored as an \c NSValue. Call \c -pointerValue to retrieve the function pointer.
 */
#define AIKEYCHAIN_ERROR_USERINFO_SETTINGSPOINTER @"PointerToSettingsStructure"

/*!	@def AIKEYCHAIN_ERROR_USERINFO_SERVICE
 *	@brief The service name passed to <code>-addGenericPasswordForService:account:keychainItem:error:</code> or <code>-findGenericPasswordForService:account:keychainItem:error:</code>.
 */
#define AIKEYCHAIN_ERROR_USERINFO_SERVICE            @"GenericPasswordService"

/*!	@def AIKEYCHAIN_ERROR_USERINFO_SERVER
 *	@brief The service name passed to <code>-addInternetPassword:forService:securityDomain:account:path:port:protocol:authenticationType:keychainItem:error:</code> or <code>-findInternetPasswordForServer:securityDomain:account:path:port:protocol:authenticationType:keychainItem:error:</code>.
 */
#define AIKEYCHAIN_ERROR_USERINFO_SERVER             @"InternetPasswordServer"

/*!	@def AIKEYCHAIN_ERROR_USERINFO_DOMAIN
 *	@brief The service name passed to <code>-addInternetPassword:forService:securityDomain:account:path:port:protocol:authenticationType:keychainItem:error:</code> or <code>-findInternetPasswordForServer:securityDomain:account:path:port:protocol:authenticationType:keychainItem:error:</code>.
 */
#define AIKEYCHAIN_ERROR_USERINFO_DOMAIN             @"InternetPasswordSecurityDomain"

/*!	@def AIKEYCHAIN_ERROR_USERINFO_ACCOUNT
 *	@brief The service name passed to <code>-addInternetPassword:forService:securityDomain:account:path:port:protocol:authenticationType:keychainItem:error:</code>, <code>-findInternetPasswordForServer:securityDomain:account:path:port:protocol:authenticationType:keychainItem:error:</code>, <code>-addGenericPasswordForService:account:keychainItem:error:</code>, or <code>-findGenericPasswordForService:account:keychainItem:error:</code>.
 */
#define AIKEYCHAIN_ERROR_USERINFO_ACCOUNT            @"PasswordAccount"

/*!	@def AIKEYCHAIN_ERROR_USERINFO_PROTOCOL
 *	@brief The service name passed to <code>-addInternetPassword:forService:securityDomain:account:path:port:protocol:authenticationType:keychainItem:error:</code> or <code>-findInternetPasswordForServer:securityDomain:account:path:port:protocol:authenticationType:keychainItem:error:</code>.
 */
#define AIKEYCHAIN_ERROR_USERINFO_PROTOCOL           @"PasswordProtocol"

/*!	@def AIKEYCHAIN_ERROR_USERINFO_AUTHENTICATIONTYPE
 *	@brief The service name passed to <code>-addInternetPassword:forService:securityDomain:account:path:port:protocol:authenticationType:keychainItem:error:</code> or <code>-findInternetPasswordForServer:securityDomain:account:path:port:protocol:authenticationType:keychainItem:error:</code>.
 */
#define AIKEYCHAIN_ERROR_USERINFO_AUTHENTICATIONTYPE @"PasswordAuthenticationType"

/*@}*/

/*!	class AIKeychain
 *	@brief Wrapper for Keychain Services keychain objects.
 *
 *	@par
 *	Cocoa wrapper which offers class methods for accessing the default keychain and others, and instance methods for accessing data from the keychains.
 */
@interface DDKeychain: NSObject {
	SecKeychainRef keychainRef;
}

/*!	@brief Locks all of the user's keychains.
 *
 *	Wraps \c SecKeychainLockAll.
 *
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return \c BOOL (Success/Failure)
 */
+ (BOOL)lockAllKeychains_error:(__strong NSError **)outError;

/*!	@brief Locks the user's default keychain.
 *
 *	Wraps \c SecKeychainLock, passing \c NULL as the keychain to lock.
 *
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return \c BOOL (Success/Failure)
 */
+ (BOOL)lockDefaultKeychain_error:(__strong NSError **)outError;

/*!	@brief Unlocks the user's default keychain.
 *
 *	@par
 *	Wraps \c SecKeychainUnlock, passing \c NULL as the keychain to unlock.
 *
 *	@par
 *	The user will be prompted for the password with which to unlock the keychain if user interaction is allowed (see \c +allowsUserInteraction_error:).
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return \c YES if the keychain was successfully unlocked; \c NO if the password was incorrect or an error occurred.
 */
+ (BOOL)unlockDefaultKeychain_error:(__strong NSError **)outError;

/*!	@brief Unlocks the user's default keychain with a specific password.
 *
 *	Wraps \c SecKeychainUnlock, passing \c NULL as the keychain to unlock.
 *
 *	@param password The password to try to unlock the keychain with. If the password is incorrect, \c NO and an \c NSError will be returned.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return \c YES if the keychain was successfully unlocked; \c NO if the password was incorrect or an error occurred.
 */
+ (BOOL)unlockDefaultKeychainWithPassword:(NSString *)password error:(__strong NSError **)outError;

/*!	@brief Returns whether Keychain Services should use its user interface.
 *
 *	Wraps \c SecKeychainGetUserInteractionAllowed.
 *
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return \c YES if user interaction is allowed; \c NO if not, or if an error occurred.
 */
+ (BOOL)allowsUserInteraction_error:(__strong NSError **)outError;

/*!	@brief Sets whether Keychain Services should use its user interface.
 *
 *	Wraps \c SecKeychainSetUserInteractionAllowed.
 *
 *	@param flag \c YES if user interaction should be allowed; \c NO if not.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 */
+ (BOOL)setAllowsUserInteraction:(BOOL)flag error:(__strong NSError **)outError;

/*!	@brief Returns the version of the Keychain Services API.
 *	Wraps \c SecKeychainGetVersion.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return A version number. As of Mac OS X 10.4.6, the current version is \c SEC_KEYCHAIN_SETTINGS_VERS1.
 */
+ (u_int32_t)keychainServicesVersion_error:(__strong NSError **)outError;

#pragma mark -

/*!	@brief	Gets the default keychain.
 *
 *	@par
 *	Wraps \c SecKeychainCopyDefault.
 *
 *	@par
 *	As long as the default keychain does not change, the same \c AIKeychain instance will be returned. If it does change, a new one will be created. It is possible to get two <code>AIKeychain</code>s for the same keychain, if the default keychain changes and then changes back.
 *
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return An \c AIKeychain instance that wraps the current default keychain.
 */
+ (DDKeychain *)defaultKeychain_error:(__strong NSError **)outError;

/*!	@brief	Sets the default keychain.
 *
 *	@par
 *	Wraps \c SecKeychainSetDefault.
 *
 *	@par
 *	The default keychain will be set using the Keychain Services \c KeychainRef inside the passed \c AIKeychain.
 *
 *	@param newDefaultKeychain An \c AIKeychain instance that wraps the intended default keychain.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return \c BOOL (Success/Failure)
 */
+ (BOOL)setDefaultKeychain:(DDKeychain *)newDefaultKeychain error:(__strong NSError **)outError;

/*!	@brief Loads a keychain from a file.
 *
 *	Wraps \c SecKeychainOpen.
 *
 *	@param path The path to the keychain file to load.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return A shiny new autoreleased \c AIKeychain.
 */
+ (DDKeychain *)keychainWithContentsOfFile:(NSString *)path error:(__strong NSError **)outError;

/*!	@brief Loads a keychain from a file.
 *
 *	Wraps \c SecKeychainOpen.
 *
 *	@param path The path to the keychain file to load.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return A shiny new \c AIKeychain.
 */
- (id)initWithContentsOfFile:(NSString *)path error:(__strong NSError **)outError;

/*!	@brief Creates a new keychain from scratch.
 *
 *	Wraps \c SecKeychainCreate.
 *
 *	@param path The location at which to save the keychain file.
 *	@param password The initial password of the keychain. Can be \c nil; in this case, you should pass \c YES for \a prompt.
 *	@param prompt If \c YES, ignores \a password and prompts the user for a password. If \c NO, \a password is used.
 *	@param initialAccess The initial access rights for the keychain. Can be \c nil.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@result A shiny new autoreleased \c AIKeychain.
 */
+ (DDKeychain *)keychainWithPath:(NSString *)path password:(NSString *)password promptUser:(BOOL)prompt initialAccess:(SecAccessRef)initialAccess error:(__strong NSError **)outError;

/*!	@brief Creates a new keychain from scratch.
 *
 *	Wraps \c SecKeychainCreate.
 *
 *	@param path The location at which to save the keychain file.
 *	@param password The initial password of the keychain. Can be \c nil; in this case, you should pass \c YES for \a prompt.
 *	@param prompt If \c YES, ignores \a password and prompts the user for a password. If \c NO, \a password is used.
 *	@param initialAccess The initial access rights for the keychain. Can be \c nil.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@result A shiny new \c AIKeychain.
 */
- (id)initWithPath:(NSString *)path
		  password:(NSString *)password //can be nil if promptUser is true
		promptUser:(BOOL)prompt
	 initialAccess:(SecAccessRef)initialAccess //can be NULL
			 error:(__strong NSError **)outError;

/*!	@brief Creates a new \c AIKeychain wrapper for an existing keychain object.
 *
 *	When you already have a Keychain Services \c SecKeychainRef for a keychain, use this to wrap it in yummy \c AIKeychain goodness.
 *
 *	@param newKeychainRef The Keychain Services keychain object to wrap. This will be retained by the \c AIKeychain instance.
 *	@return A shiny new autoreleased \c AIKeychain.
 */
+ (DDKeychain *)keychainWithKeychainRef:(SecKeychainRef)newKeychainRef;

/*!	@brief Creates a new \c AIKeychain wrapper for an existing keychain object.
 *
 *	When you already have a Keychain Services \c SecKeychainRef for a keychain, use this to wrap it in yummy \c AIKeychain goodness.
 *
 *	@param newKeychainRef The Keychain Services keychain object to wrap. This will be retained by the \c AIKeychain instance.
 *	@return A shiny new \c AIKeychain.
 */
- (id)initWithKeychainRef:(SecKeychainRef)newKeychainRef;

#pragma mark -

/*!	@brief Gets the current settings of the keychain.
 *
 *	Wraps \c SecKeychainCopySettings.
 *
 *	@param outSettings The destination to which the settings should be copied.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return \c BOOL (Success/Failure)
 */
- (BOOL)getSettings:(out struct SecKeychainSettings *)outSettings error:(__strong NSError **)outError;

/*!	@brief Sets the current settings of the keychain.
 *
 *	Wraps \c SecKeychainSetSettings.
 *
 *	@param newSettings The new settings. These will be copied, so the memory does not need to persist after this call.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return \c BOOL (Success/Failure)
 */
- (BOOL)setSettings:( in struct SecKeychainSettings *)newSettings error:(__strong NSError **)outError;

/*!	@brief Gets the current status (locked state and writability) of the keychain.
 *
 *	Wraps \c SecKeychainGetStatus.
 *
 *	@return The status of the keychain, as a bit-mask.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 */
- (SecKeychainStatus)status_error:(__strong NSError **)outError;

/*!	@brief Gets the path to the keychain file.
 *
 *	@par
 *	Wraps \c SecKeychainGetPath.
 *
 *	@par
 *	The path is copied to a buffer you supply (\a outBuf), up to a maximum number of characters (\a outLength). On return, \a *outLength is the number of bytes copied. \a outBuf will be \c NUL-terminated, so you may pass it to POSIX functions if you so choose. \a *outLength does not include the terminating \c NUL; if the path is "foo", \a *outLength will be \c 3.
 *
 *	@param outBuf The buffer into which to copy the path.
 *	@param outLength As input, a pointer to the maximum number of bytes to copy. As output, a pointer to the number of bytes copied, not counting the terminating \c NUL.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return \a outBuf.
 */
- (char *)getPathFileSystemRepresentation:(out char *)outBuf length:(inout u_int32_t *)outLength error:(__strong NSError **)outError;

/*!	@brief Gets the path to the keychain file as an \c NSString.
 *
 *	@par
 *	Wraps \c SecKeychainGetPath.
 *
 *	@return The path to the keychain file.
 */
- (NSString *)path;

#pragma mark -

/*!	@brief Locks the keychain.
 *
 *	Wraps \c SecKeychainLock.
 *
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return \c BOOL (Success/Failure)
 */
- (BOOL)lockKeychain_error:(__strong NSError **)outError;

/*!	@brief Unlocks the keychain.
 *
 *	@par
 *	Wraps \c SecKeychainUnlock.
 *
 *	@par
 *	The user will be prompted for the password with which to unlock the keychain if user interaction is allowed (see \c +allowsUserInteraction_error:).
 *
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return \c YES if the keychain was successfully unlocked; \c NO if the password was incorrect or an error occurred.
 */
- (BOOL)unlockKeychain_error:(__strong NSError **)outError;

/*!	@brief Unlocks the keychain with a specific password.
 *
 *	@par
 *	Wraps \c SecKeychainUnlock.
 *
 *	@par
 *	The user will be prompted for the password with which to unlock the keychain if user interaction is allowed (see \c +allowsUserInteraction_error:).
 *
 *	@param password The password to try to unlock the keychain with. If the password is incorrect, \c NO and an \c NSError will be returned.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return \c YES if the keychain was successfully unlocked; \c NO if the password was incorrect or an error occurred.
 */
- (BOOL)unlockKeychainWithPassword:(NSString *)password error:(__strong NSError **)outError;

#pragma mark -

/*!	@brief Deletes the keychain.
 *
 *	@par
 *	Wraps \c SecKeychainDelete.	
 *
 *	@par
 *	\c SecKeychainDelete will not delete a keychain unless it is a local file.
 *	Even if the keychain is successfully deleted, the \c AIKeychain instance will still be around until it has been released by all owners. You just won't be able to use it.
 *	@return \c BOOL (Success/Failure)
 *
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 */
- (BOOL)deleteKeychain_error:(__strong NSError **)outError;

#pragma mark -

/*Working with keychain items
 *
 *Like all AIKeychain methods, \a outError is optional (can be \c NULL).
 *\a outKeychainItem is also optional. If it is non-\c NULL, you must release the
 *	keychain item.
 */

/*!	@brief Adds an Internet password.
 *
 *	@par
 *	Wraps \c SecKeychainAddInternetPassword.
 *
 *	@par
 *	If the password already exists, the error object's code will be \c errSecDuplicateItem.
 *
 *	@param password The password to add.
 *	@param server The server that the password can be used to log into.
 *	@param domain The security domain of the keychain item. Can be \c nil.
 *	@param account The username of the account.
 *	@param path The path of the resource that the username and password control.
 *	@param port The TCP/IP port of the service via which authentication should occur. If this doesn't apply, pass \c 0.
 *	@param protocol The protocol of the service via which authentication should occur.
 *	@param authType The type of authentication to use.
 *	@param outKeychainItem On return, a pointer to the keychain item that was created and added. Can be \c NULL. If it is non-\c NULL, you are responsible for releasing the keychain item.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return \c BOOL (Success/Failure)
 */
- (BOOL)addInternetPassword:(NSString *)password
				  forServer:(NSString *)server
			 securityDomain:(NSString *)domain //can pass nil
					account:(NSString *)account
					   path:(NSString *)path
					   port:(u_int16_t)port //can pass 0
				   protocol:(SecProtocolType)protocol
		 authenticationType:(SecAuthenticationType)authType
			   keychainItem:(out SecKeychainItemRef *)outKeychainItem
					  error:(__strong NSError **)outError;

/*!	@brief Adds an Internet password (convenience version).
 *
 *	@par
 *	Wraps \c SecKeychainAddInternetPassword via <code>addInternetPassword:forServer:securityDomain:account:path:port:protocol:authenticationType:keychainItem:error:</code>. \a domain and \a path are \c nil, \a port is \c 0, \a authType is \c kSecAuthenticationTypeDefault, and \a outKeychainItem is \c NULL.
 *
 *	@par
 *	If the password already exists, the error object's code will be \c errSecDuplicateItem.
 *
 *	@param password The password to add.
 *	@param server The server that the password can be used to log into.
 *	@param account The username of the account.
 *	@param protocol The protocol of the service via which authentication should occur.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return \c BOOL (Success/Failure)
 */
- (BOOL)addInternetPassword:(NSString *)password
				  forServer:(NSString *)server
					account:(NSString *)account
				   protocol:(SecProtocolType)protocol
					  error:(__strong NSError **)outError;

#pragma mark -

/*!	@brief Retrieves an Internet password.
 *
 *	@par
 *	@par
 *	Wraps \c SecKeychainFindInternetPassword.
 *
 *	@par
 *	If no keychain item is matched, the error object's code will be \c errSecItemNotFound.
 *
 *	@param server The server that the password can be used to log into.
 *	@param domain The security domain of the keychain item. Can be \c nil.
 *	@param account The username of the account.
 *	@param path The path of the resource that the username and password control.
 *	@param port The TCP/IP port of the service via which authentication should occur. If this doesn't apply, pass \c 0.
 *	@param protocol The protocol of the service via which authentication should occur.
 *	@param authType The type of authentication to use.
 *	@param outKeychainItem On return, a pointer to the keychain item that was retieved. Can be \c NULL.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return The password of the matching keychain item, or \c nil if no keychain item matched.
 */
- (NSString *)findInternetPasswordForServer:(NSString *)server
							 securityDomain:(NSString *)domain //can pass nil
									account:(NSString *)account
									   path:(NSString *)path
									   port:(u_int16_t)port //can pass 0
								   protocol:(SecProtocolType)protocol
						 authenticationType:(SecAuthenticationType)authType
							   keychainItem:(out SecKeychainItemRef *)outKeychainItem
									  error:(__strong NSError **)outError;

/*!	@brief Retrieves an Internet password (convenience version).
 *
 *	@par
 *	Wraps \c SecKeychainFindInternetPassword via <code>findInternetPasswordForServer:securityDomain:account:path:port:protocol:authenticationType:keychainItem:error:</code>. \a domain and \a path are \c nil, \a port is \c 0, \a authType is \c kSecAuthenticationTypeDefault, and \a outKeychainItem is \c NULL.
 *
 *	@par
 *	If no keychain item is matched, the error object's code will be \c errSecItemNotFound.
 *
 *	@param server The server that the password can be used to log into.
 *	@param account The username of the account.
 *	@param protocol The protocol of the service via which authentication should occur.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return The password of the matching keychain item, or \c nil if no keychain item matched.
 */
- (NSString *)internetPasswordForServer:(NSString *)server
								account:(NSString *)account
							   protocol:(SecProtocolType)protocol
								  error:(__strong NSError **)outError;

/*!	@brief Retrieves an Internet password (dictionary method).
 *
 * This method returns a dictionary with both the username and password for connecting to the specified server/protocol
 * combination.
 *
 *	@param server The server that the password can be used to log into.
 *	@param protocol The protocol of the service via which authentication should occur.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return A dictionary containing two keys: @"Username" (account), @"Password". If no matching keychain item exists, \c nil is returned.
 */
- (NSDictionary *)dictionaryFromKeychainForServer:(NSString *)server protocol:(SecProtocolType)protocol error:(__strong NSError **)outError;

#pragma mark -

/*!	@brief Adds, changes, or deletes an Internet password.
 *
 *	@par
 *	Wraps \c SecKeychainAddInternetPassword, \c SecKeychainItemModifyAttributesAndData, <code>findInternetPasswordForServer:securityDomain:account:path:port:protocol:authenticationType:keychainItem:error:</code>, and \c SecKeychainItemDelete.
 *
 *	@par
 *	- If \a password is not \c nil, and a matching keychain item exists, the password is changed.
 *	- If \a password is not \c nil, and a matching keychain item does not exist, the password is added.
 *	- If \a password is \c nil, the password is removed.
 *
 *	@param password The password to add.
 *	@param server The server that the password can be used to log into.
 *	@param domain The security domain of the keychain item. Can be \c nil.
 *	@param account The username of the account.
 *	@param path The path of the resource that the username and password control.
 *	@param port The TCP/IP port of the service via which authentication should occur. If this doesn't apply, pass \c 0.
 *	@param protocol The protocol of the service via which authentication should occur.
 *	@param authType The type of authentication to use.
 *	@param outKeychainItem On return, a pointer to the keychain item that was created and added. Can be \c NULL.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return \c BOOL (Success/Failure)
 */
- (BOOL)setInternetPassword:(NSString *)password
				  forServer:(NSString *)server
			 securityDomain:(NSString *)domain //can pass nil
					account:(NSString *)account
					   path:(NSString *)path
					   port:(u_int16_t)port //can pass 0
				   protocol:(SecProtocolType)protocol
		 authenticationType:(SecAuthenticationType)authType
			   keychainItem:(out SecKeychainItemRef *)outKeychainItem
					  error:(__strong NSError **)outError;

/*!	@brief Adds, changes, or deletes an Internet password (convenience version).
 *
 *	@par
 *	Wraps <code>setInternetPassword:forServer:securityDomain:account:path:port:protocol:authenticationType:keychainItem:error:</code>. \a domain and \a path are \c nil, \a port is \c 0, \a authType is \c kSecAuthenticationTypeDefault, and \a outKeychainItem is \c NULL.
 *
 *	@par
 *	- If \a password is not \c nil, and a matching keychain item exists, the password is changed.
 *	- If \a password is not \c nil, and a matching keychain item does not exist, the password is added.
 *	- If \a password is \c nil, the password is removed.
 *
 *	@param password The password to add.
 *	@param server The server that the password can be used to log into.
 *	@param account The username of the account.
 *	@param protocol The protocol of the service via which authentication should occur.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return \c BOOL (Success/Failure)
 */
- (BOOL)setInternetPassword:(NSString *)password
				  forServer:(NSString *)server
					account:(NSString *)account
				   protocol:(SecProtocolType)protocol
					  error:(__strong NSError **)outError;

#pragma mark -

/*!	@brief Deletes an Internet password.
 *
 *	@par
 *	Wraps \c SecKeychainItemDelete.
 *
 *	@param server The server that the password can be used to log into.
 *	@param domain The security domain of the keychain item. Can be \c nil.
 *	@param account The username of the account.
 *	@param path The path of the resource that the username and password control.
 *	@param port The TCP/IP port of the service via which authentication should occur. If this doesn't apply, pass \c 0.
 *	@param protocol The protocol of the service via which authentication should occur.
 *	@param authType The type of authentication to use.
 *	@param outKeychainItem On return, a pointer to the keychain item that was created and added. Can be \c NULL.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return \c BOOL (Success/Failure)
 */
- (BOOL)deleteInternetPasswordForServer:(NSString *)server
						 securityDomain:(NSString *)domain //can pass nil
								account:(NSString *)account
								   path:(NSString *)path
								   port:(u_int16_t)port //can pass 0
							   protocol:(SecProtocolType)protocol
					 authenticationType:(SecAuthenticationType)authType
						   keychainItem:(out SecKeychainItemRef *)outKeychainItem
								  error:(__strong NSError **)outError;

/*!	@brief Deletes an Internet password (convenience version).
 *
 *	@par
 *	Wraps <code>deleteInternetPassword:forServer:securityDomain:account:path:port:protocol:authenticationType:keychainItem:error:</code>. \a domain and \a path are \c nil, \a port is \c 0, \a authType is \c kSecAuthenticationTypeDefault, and \a outKeychainItem is \c NULL.
 *
 *	@param server The server that the password can be used to log into.
 *	@param account The username of the account.
 *	@param protocol The protocol of the service via which authentication should occur.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return \c BOOL (Success/Failure)
 */
- (BOOL)deleteInternetPasswordForServer:(NSString *)server
								account:(NSString *)account
							   protocol:(SecProtocolType)protocol
								  error:(__strong NSError **)outError;

#pragma mark -

/*!	@brief Adds a generic password.
 *
 *	@par
 *	Wraps \c SecKeychainAddGenericPassword.
 *
 *	@par
 *	If the password already exists, the error object's code will be \c errSecDuplicateItem.
 *
 *	@param password The password to add.
 *	@param service The service that the password can be used to log into.
 *	@param account The username of the account.
 *	@param outKeychainItem On return, a pointer to the keychain item that was created and added. Can be \c NULL. If you pass non-\c NULL, you are responsible for releasing the keychain item.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return \c BOOL (Success/Failure)
 */
- (BOOL)addGenericPassword:(NSString *)password
				forService:(NSString *)service
				   account:(NSString *)account
			  keychainItem:(out SecKeychainItemRef *)outKeychainItem
					 error:(__strong NSError **)outError;

/*!	@brief Retrieves a generic password.
 *
 *	@par
 *	Wraps \c SecKeychainFindGenericPassword.
 *
 *	@par
 *	If no keychain item is matched, the error object's code will be \c errSecItemNotFound.
 *
 *	@param service The service that the password can be used to log into.
 *	@param account The username of the account.
 *	@param outKeychainItem On return, a pointer to the keychain item that was created and added. Can be \c NULL. If you pass non-\c NULL, you are responsible for releasing the keychain item.
 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 *	@return The password of the matching keychain item, or \c nil if no keychain item matched.
 */
- (NSString *)findGenericPasswordForService:(NSString *)service
									account:(NSString *)account
							   keychainItem:(out SecKeychainItemRef *)outKeychainItem
									  error:(__strong NSError **)outError;

/*!	@brief Deletes a Generic password (convenience version).
 *
 *	@param service The service that the password can be used to log into.
 *	@param account The username of the account.

 *	@param outError On return, a pointer to either \c nil (hopefully) or an \c NSError describing what went wrong.
 */
- (BOOL)deleteGenericPasswordForService:(NSString *)service
								account:(NSString *)account
								  error:(__strong NSError **)outError;

#pragma mark -

/*!	@brief Returns the Keychain Services object that backs the \c AIKeychain.
 *
 *	Every \c AIKeychain wraps a Keychain Services \c SecKeychainRef. This method is an accessor that returns that object.
 *
 *	@return A \c SecKeychainRef. You are responsible for retaining (with \c CFRetain) and releasing (with \c CFRelease) this object as needed.
 */
- (SecKeychainRef)keychainRef;

@end
