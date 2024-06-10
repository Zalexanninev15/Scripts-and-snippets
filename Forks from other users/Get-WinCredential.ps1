<#
.Synopsis
   Shows Windows native credential dialog on PowerShell 7.x and VS Code.
.DESCRIPTION
   The cmdlet utilizes Windows native code based on P/Invoke calls. The parameters and output are the same as Get-Credential cmdlet. Based on the example: https://www.developerfusion.com/code/4693/using-the-credential-management-api/
.SYNTAX
   Get-WinCredential [[-UserName] <string>] -Message <string>  [<CommonParameters>]
.EXAMPLE
   Get-WinCredential
.EXAMPLE
   Get-WinCredential -Message "Type your credentials" -Username "test"
.EXAMPLE
   Get-WinCredential -Message "Type your credentials" -UseModernDialog
#>
function Get-WinCredential {
    [CmdletBinding(SupportsShouldProcess = $false,
        PositionalBinding = $false,
        HelpUri = 'https://gist.github.com/zbalkan/cc90b626126354fa60d5b29661a77faa',
        ConfirmImpact = 'Low')]
    [Alias()]
    [OutputType([pscredential])]
    Param
    (
        # Message help description
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,

        # Username help description
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false,
            Position = 1)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("[0-9A-Za-z_\-\.\@\\]*")]
        [string]
        $Username,

        [Parameter(Mandatory = $false)]
        [Switch]
        $UseModernDialog
    )

    Begin {
        try {
            $null = [CredentialWindow.CredentialsDialog]::new()
        } catch {
            Add-Type -TypeDefinition @"
using System;
using System.Globalization;
using System.Runtime.InteropServices;
using System.Security;
using System.Text;
using System.Windows.Forms;

namespace CredentialWindow
{
    /// <summary>Encapsulates dialog functionality from the Credential Management API.</summary>
    public sealed class CredentialsDialog
    {
        /// <summary>Initializes a new instance of the <see cref="T:CredentialWindow.CredentialsDialog"/> class
        /// with the specified message.</summary>
        /// <param name="message">The message of the dialog (null will cause a system default message to be used).</param>
        /// <param name="useModernUI">Use Vista+ dialog</param>
        public CredentialsDialog(string message = "", bool useModernUI = false)
        {
            _target = "PowerShell";
            if (string.IsNullOrEmpty(message))
            {
                _message = "Enter your credentials.";
            }
            else
            {
                _message = message;
            }
            _useModernUI = useModernUI;

            // Keep the default values
            _alwaysDisplay = true;
            _excludeCertificates = true;
            _persist = false;
            _keepName = false;
            _saveChecked = false;
            _saveDisplayed = false;
        }

        /// <summary>
        /// Gets or sets if the dialog will be shown even if the credentials
        /// can be returned from an existing credential in the credential manager.
        /// </summary>
        private bool _alwaysDisplay;

        /// <summary>Gets or sets if the dialog is populated with username/password only.</summary>
        private bool _excludeCertificates;

        /// <summary>Gets or sets if the credentials are to be persisted in the credential manager.</summary>
        private bool _persist;

        /// <summary>Gets or sets if the username is read-only.</summary>
        private bool _keepName;

        /// <summary>Gets or sets if modern dialog is used or not.</summary>
        private bool _useModernUI;

        private string _name = string.Empty;
        /// <summary>Gets or sets the username for the credentials.</summary>
        public string Name
        {
            get
            {
                return _name;
            }
            set
            {
                if (value != null)
                {
                    if (value.Length > CREDUI.MAX_USERNAME_LENGTH)
                    {
                        var message = string.Format(
                            CultureInfo.InvariantCulture,
                            "The username has a maximum length of {0} characters.",
                            CREDUI.MAX_USERNAME_LENGTH);
                        throw new ArgumentException(message, "Name");
                    }
                }
                _name = value;
            }
        }

        private SecureString _password = null;

        /// <summary>Gets or sets the password for the credentials.</summary>
        public SecureString Password
        {
            get
            {
                return _password;
            }
            set
            {
                if (value != null)
                {
                    if (value.Length > CREDUI.MAX_PASSWORD_LENGTH)
                    {
                        var message = string.Format(
                            CultureInfo.InvariantCulture,
                            "The password has a maximum length of {0} characters.",
                            CREDUI.MAX_PASSWORD_LENGTH);
                        throw new ArgumentException(message, "Password");
                    }
                }
                // Convert to secure string here

                _password = value;
            }
        }

        private static SecureString ConvertToSecureString(string value)
        {
            var secureString = new SecureString();
            foreach (var c in value)
            {
                secureString.AppendChar(c);
            }
            return secureString;
        }

        /// <summary>Gets or sets if the save checkbox status.</summary>
        private bool _saveChecked;

        /// <summary>Gets or sets if the save checkbox is displayed.</summary>
        /// <remarks>This value only has effect if _persist is true.</remarks>
        private bool _saveDisplayed;

        /// <summary>Gets or sets the username of the target for the credentials, typically a server username.</summary>
        private string _target;

        private string _messageValue;
        /// <summary>Gets or sets the message of the dialog.</summary>
        /// <remarks>A null value will cause a system default message to be used.</remarks>
        private string _message
        {
            get
            {
                return _messageValue;
            }
            set
            {
                if (value != null)
                {
                    if (value.Length > CREDUI.MAX_MESSAGE_LENGTH)
                    {
                        var message = string.Format(
                            CultureInfo.InvariantCulture,
                            "The message has a maximum length of {0} characters.",
                            CREDUI.MAX_MESSAGE_LENGTH);
                        throw new ArgumentException(message, "Message");
                    }
                }
                _messageValue = value;
            }
        }

        /// <summary>Shows the credentials dialog with the specified owner, username, password and save checkbox status.</summary>
        /// <param name="username">The username for the credentials.</param>
        /// <returns>Returns a DialogResult indicating the user action.</returns>
        public DialogResult Show(string username = "")
        {
            if (string.IsNullOrEmpty(username))
            {
                username = "";
            }
            Name = username;
            _saveChecked = false;

            return ShowDialog(null);
        }

        /// <summary>Returns a DialogResult indicating the user action.</summary>
        /// <param name="owner">The System.Windows.Forms.IWin32Window the dialog will display in front of.</param>
        /// <remarks>
        /// Sets the username, password and SaveChecked accessors to the state of the dialog as it was dismissed by the user.
        /// </remarks>
        private DialogResult ShowDialog(IWin32Window owner)
        {
            // set the api call parameters
            var name = new StringBuilder(CREDUI.MAX_USERNAME_LENGTH);
            name.Append(Name);

            var password = new StringBuilder(CREDUI.MAX_PASSWORD_LENGTH);
            password.Append(string.Empty);

            var saveChecked = Convert.ToInt32(_saveChecked);

            var info = GetInfo(owner);

            // make the api call
            if (_useModernUI)
            {
                uint authPackage = 0;
                var code = CREDUI.CredUIPromptForWindowsCredentials(ref info,
                    0,
                    ref authPackage,
                    IntPtr.Zero,
                    0,
                    out var outCredBuffer,
                    out var outCredSize,
                    ref _saveChecked,
                    CREDUI.FLAGS_MODERN_UI.CREDUIWIN_GENERIC);

                var domainBuf = new StringBuilder(100);

                var maxUserName = CREDUI.MAX_USERNAME_LENGTH;
                var maxDomain = CREDUI.MAX_DOMAIN_TARGET_LENGTH;
                var maxPassword = CREDUI.MAX_PASSWORD_LENGTH;
                if (code == CREDUI.ReturnCodesModernUI.NO_ERROR)
                {
                    if (CREDUI.CredUnPackAuthenticationBuffer(0, outCredBuffer, outCredSize, name, ref maxUserName,
                            domainBuf, ref maxDomain, password, ref maxPassword))
                    {
                        //clear the memory allocated by CredUIPromptForWindowsCredentials 
                        CREDUI.CoTaskMemFree(outCredBuffer);

                        SetCredentialsModern(name, password);
                    }
                }

                return GetDialogResultModernUI(code);
            }
            else
            {
                var flags = GetFlags();
                var code = CREDUI.PromptForCredentials(
                    ref info,
                    _target,
                    IntPtr.Zero,
                    0,
                    name,
                    CREDUI.MAX_USERNAME_LENGTH,
                    password,
                    CREDUI.MAX_PASSWORD_LENGTH,
                    ref saveChecked,
                    flags
                );

                // set the accessors from the api call parameters
                SetCredentials(name, password, saveChecked);

                return GetDialogResult(code);
            }

            void SetCredentials(StringBuilder n, StringBuilder pw, int save)
            {
                Name = n.ToString();
                Password = ConvertToSecureString(pw.ToString());
                _saveChecked = Convert.ToBoolean(save);
            }

            void SetCredentialsModern(StringBuilder n, StringBuilder pw)
            {
                Name = n.ToString();
                Password = ConvertToSecureString(pw.ToString());
            }
        }

        /// <summary>Returns the info structure for dialog display settings.</summary>
        /// <param name="owner">The System.Windows.Forms.IWin32Window the dialog will display in front of.</param>
        private CREDUI.INFO GetInfo(IWin32Window owner)
        {
            var info = new CREDUI.INFO();
            if (owner != null) info.hwndParent = owner.Handle;
            info.pszCaptionText = null;
            info.pszMessageText = _message;
            info.cbSize = Marshal.SizeOf(info);
            return info;
        }

        /// <summary>Returns the flags for dialog display options.</summary>
        private CREDUI.FLAGS GetFlags()
        {
            var flags = CREDUI.FLAGS.GENERIC_CREDENTIALS;

            // grrrr... can't seem to get this to work...
            // if (incorrectPassword) flags = flags | CredUI.CREDUI_FLAGS.INCORRECT_PASSWORD;

            if (_alwaysDisplay) flags |= CREDUI.FLAGS.ALWAYS_SHOW_UI;

            if (_excludeCertificates) flags |= CREDUI.FLAGS.EXCLUDE_CERTIFICATES;

            if (_persist)
            {
                flags |= CREDUI.FLAGS.EXPECT_CONFIRMATION;
                if (_saveDisplayed) flags |= CREDUI.FLAGS.SHOW_SAVE_CHECK_BOX;
            }
            else
            {
                flags |= CREDUI.FLAGS.DO_NOT_PERSIST;
            }

            if (_keepName) flags |= CREDUI.FLAGS.KEEP_USERNAME;

            return flags;
        }


        /// <summary>Returns a DialogResult from the specified code.</summary>
        /// <param name="code">The credential return code.</param>
        private static DialogResult GetDialogResult(CREDUI.ReturnCodes code)
        {
            switch (code)
            {
                case CREDUI.ReturnCodes.NO_ERROR:
                    return DialogResult.OK;
                case CREDUI.ReturnCodes.ERROR_CANCELLED:
                    return DialogResult.Cancel;
                case CREDUI.ReturnCodes.ERROR_NO_SUCH_LOGON_SESSION:
                    throw new ApplicationException("No such logon session.");
                case CREDUI.ReturnCodes.ERROR_NOT_FOUND:
                    throw new ApplicationException("Not found.");
                case CREDUI.ReturnCodes.ERROR_INVALID_ACCOUNT_NAME:
                    throw new ApplicationException("Invalid account username.");
                case CREDUI.ReturnCodes.ERROR_INSUFFICIENT_BUFFER:
                    throw new ApplicationException("Insufficient buffer.");
                case CREDUI.ReturnCodes.ERROR_INVALID_PARAMETER:
                    throw new ApplicationException("Invalid parameter.");
                case CREDUI.ReturnCodes.ERROR_INVALID_FLAGS:
                    throw new ApplicationException("Invalid flags.");
                default:
                    throw new ApplicationException("Unknown credential result encountered.");
            }
        }

        /// <summary>Returns a DialogResult from the specified code.</summary>
        /// <param name="code">The credential return code.</param>
        private static DialogResult GetDialogResultModernUI(CREDUI.ReturnCodesModernUI code)
        {
            switch (code)
            {
                case CREDUI.ReturnCodesModernUI.NO_ERROR:
                    return DialogResult.OK;
                case CREDUI.ReturnCodesModernUI.ERROR_CANCELLED:
                    return DialogResult.Cancel;
                case CREDUI.ReturnCodesModernUI.ERROR_NO_SUCH_LOGON_SESSION:
                    throw new ApplicationException("No such logon session.");
                case CREDUI.ReturnCodesModernUI.ERROR_NOT_FOUND:
                    throw new ApplicationException("Not found.");
                case CREDUI.ReturnCodesModernUI.ERROR_INVALID_ACCOUNT_NAME:
                    throw new ApplicationException("Invalid account username.");
                case CREDUI.ReturnCodesModernUI.ERROR_INSUFFICIENT_BUFFER:
                    throw new ApplicationException("Insufficient buffer.");
                case CREDUI.ReturnCodesModernUI.ERROR_INVALID_PARAMETER:
                    throw new ApplicationException("Invalid parameter.");
                case CREDUI.ReturnCodesModernUI.ERROR_INVALID_FLAGS:
                    throw new ApplicationException("Invalid flags.");
                default:
                    throw new ApplicationException("Unknown credential result encountered.");
            }
        }

        internal static class CREDUI
        {
            /// <summary>http://msdn.microsoft.com/library/default.asp?url=/library/en-us/secauthn/security/authentication_constants.asp</summary>
            public const int MAX_MESSAGE_LENGTH = 100;
            public const int MAX_CAPTION_LENGTH = 100;
            public const int MAX_GENERIC_TARGET_LENGTH = 100;
            public const int MAX_DOMAIN_TARGET_LENGTH = 100;
            public const int MAX_USERNAME_LENGTH = 100;
            public const int MAX_PASSWORD_LENGTH = 100;

            /// <summary>
            /// http://www.pinvoke.net/default.aspx/Enums.CREDUI_FLAGS
            /// http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dnnetsec/html/dpapiusercredentials.asp
            /// http://msdn.microsoft.com/library/default.asp?url=/library/en-us/secauthn/security/creduipromptforcredentials.asp
            /// </summary>
            [Flags]
            public enum FLAGS
            {
                INCORRECT_PASSWORD = 0x1,
                DO_NOT_PERSIST = 0x2,
                REQUEST_ADMINISTRATOR = 0x4,
                EXCLUDE_CERTIFICATES = 0x8,
                REQUIRE_CERTIFICATE = 0x10,
                SHOW_SAVE_CHECK_BOX = 0x40,
                ALWAYS_SHOW_UI = 0x80,
                REQUIRE_SMARTCARD = 0x100,
                PASSWORD_ONLY_OK = 0x200,
                VALIDATE_USERNAME = 0x400,
                COMPLETE_USERNAME = 0x800,
                PERSIST = 0x1000,
                SERVER_CREDENTIAL = 0x4000,
                EXPECT_CONFIRMATION = 0x20000,
                GENERIC_CREDENTIALS = 0x40000,
                USERNAME_TARGET_CREDENTIALS = 0x80000,
                KEEP_USERNAME = 0x100000,
            }

            /// <summary>http://www.pinvoke.net/default.aspx/Enums.CredUIReturnCodes</summary>
            public enum ReturnCodes
            {
                NO_ERROR = 0,
                ERROR_INVALID_PARAMETER = 87,
                ERROR_INSUFFICIENT_BUFFER = 122,
                ERROR_INVALID_FLAGS = 1004,
                ERROR_NOT_FOUND = 1168,
                ERROR_CANCELLED = 1223,
                ERROR_NO_SUCH_LOGON_SESSION = 1312,
                ERROR_INVALID_ACCOUNT_NAME = 1315
            }

            /// <summary>
            /// http://www.pinvoke.net/default.aspx/Structures.CREDUI_INFO
            /// http://msdn.microsoft.com/library/default.asp?url=/library/en-us/secauthn/security/credui_info.asp
            /// </summary>
            public struct INFO
            {
                public int cbSize;
                public IntPtr hwndParent;
                [MarshalAs(UnmanagedType.LPWStr)] public string pszMessageText;
                [MarshalAs(UnmanagedType.LPWStr)] public string pszCaptionText;
                public IntPtr hbmBanner;
            }

            /// <summary>
            /// http://www.pinvoke.net/default.aspx/credui.CredUIPromptForCredentialsW
            /// http://msdn.microsoft.com/library/default.asp?url=/library/en-us/secauthn/security/creduipromptforcredentials.asp
            /// </summary>
            [DllImport("credui", EntryPoint = "CredUIPromptForCredentialsW", CharSet = CharSet.Unicode, SetLastError = true)]
            internal static extern ReturnCodes PromptForCredentials(
                ref INFO creditUR,
                string targetName,
                IntPtr reserved1,
                int iError,
                StringBuilder userName,
                int maxUserName,
                StringBuilder password,
                int maxPassword,
                ref int iSave,
                FLAGS flags
            );

            #region MODERN UI

            [Flags]
            internal enum FLAGS_MODERN_UI
            {
                /// <summary>
                /// The caller is requesting that the credential provider return the user name and password in plain text.
                /// This value cannot be combined with SECURE_PROMPT.
                /// </summary>
                CREDUIWIN_GENERIC = 0x1,
                /// <summary>
                /// The Save check box is displayed in the dialog box.
                /// </summary>
                CREDUIWIN_CHECKBOX = 0x2,
                /// <summary>
                /// Only credential providers that support the authentication package specified by the authPackage parameter should be enumerated.
                /// This value cannot be combined with CREDUIWIN_IN_CRED_ONLY.
                /// </summary>
                CREDUIWIN_AUTHPACKAGE_ONLY = 0x10,
                /// <summary>
                /// Only the credentials specified by the InAuthBuffer parameter for the authentication package specified by the authPackage parameter should be enumerated.
                /// If this flag is set, and the InAuthBuffer parameter is NULL, the function fails.
                /// This value cannot be combined with CREDUIWIN_AUTHPACKAGE_ONLY.
                /// </summary>
                CREDUIWIN_IN_CRED_ONLY = 0x20,
                /// <summary>
                /// Credential providers should enumerate only administrators. This value is intended for User Account Control (UAC) purposes only. We recommend that external callers not set this flag.
                /// </summary>
                CREDUIWIN_ENUMERATE_ADMINS = 0x100,
                /// <summary>
                /// Only the incoming credentials for the authentication package specified by the authPackage parameter should be enumerated.
                /// </summary>
                CREDUIWIN_ENUMERATE_CURRENT_USER = 0x200,
                /// <summary>
                /// The credential dialog box should be displayed on the secure desktop. This value cannot be combined with CREDUIWIN_GENERIC.
                /// Windows Vista: This value is not supported until Windows Vista with SP1.
                /// </summary>
                CREDUIWIN_SECURE_PROMPT = 0x1000,
                /// <summary>
                /// The credential provider should align the credential BLOB pointed to by the refOutAuthBuffer parameter to a 32-bit boundary, even if the provider is running on a 64-bit system.
                /// </summary>
                CREDUIWIN_PACK_32_WOW = 0x10000000,
            }

            public enum ReturnCodesModernUI
            {
                NO_ERROR = 0,
                ERROR_CANCELLED = 1223,
                ERROR_NO_SUCH_LOGON_SESSION = 1312,
                ERROR_NOT_FOUND = 1168,
                ERROR_INVALID_ACCOUNT_NAME = 1315,
                ERROR_INSUFFICIENT_BUFFER = 122,
                ERROR_INVALID_PARAMETER = 87,
                ERROR_INVALID_FLAGS = 1004
            }

            [DllImport("credui.dll", CharSet = CharSet.Unicode, SetLastError = true, CallingConvention = CallingConvention.Cdecl)]
            internal static extern ReturnCodesModernUI CredUIPromptForWindowsCredentials(ref CREDUI.INFO notUsedHere,
                int authError,
                ref uint authPackage,
                IntPtr InAuthBuffer,
                uint InAuthBufferSize,
                out IntPtr refOutAuthBuffer,
                out uint refOutAuthBufferSize,
                ref bool fSave,
                FLAGS_MODERN_UI flags);

            [DllImport("credui.dll", CharSet = CharSet.Auto)]
            internal static extern bool CredUnPackAuthenticationBuffer(int dwFlags,
                IntPtr pAuthBuffer,
                uint cbAuthBuffer,
                StringBuilder pszUserName,
                ref int pcchMaxUserName,
                StringBuilder pszDomainName,
                ref int pcchMaxDomainame,
                StringBuilder pszPassword,
                ref int pcchMaxPassword);

            [DllImport("ole32.dll", CharSet = CharSet.Auto)]
            public static extern void CoTaskMemFree(IntPtr ptr);
        }
        #endregion MODERN UI
    }
}
"@ -PassThru -ReferencedAssemblies System.Windows.Forms | Out-Null
        }
    }

    Process {
        $dialog = [CredentialWindow.CredentialsDialog]::new($Message, $UseModernDialog)
        if ($dialog.Show($Username) -eq [System.Windows.Forms.DialogResult]::OK) {
            return [pscredential]::new($dialog.Name, $dialog.Password)
        } else {
            return [pscredential]::Empty
        }
    }

    End {
        # Dispose data if needed
    }
}