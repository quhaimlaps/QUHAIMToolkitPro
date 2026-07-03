using Microsoft.Win32;
using System;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Reflection;
using System.Security.AccessControl;
using System.Security.Principal;
using System.Windows.Forms;

namespace QUHAIMToolkitProSetup
{
    internal static class Program
    {
        private const string ProductName = "QUHAIM Toolkit Pro";
        private const string Publisher = "QUHAIM Labs";
        private const string Version = "0.4.6.0";
        private const string UninstallKey = @"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\QUHAIMToolkitPro";

        [STAThread]
        private static int Main(string[] args)
        {
            try
            {
                if (args.Length > 0 && string.Equals(args[0], "/uninstall", StringComparison.OrdinalIgnoreCase))
                {
                    Uninstall();
                    return 0;
                }

                Install();
                MessageBox.Show(ProductName + " was installed successfully.", ProductName, MessageBoxButtons.OK, MessageBoxIcon.Information);
                return 0;
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, ProductName + " Setup", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return 1;
            }
        }

        private static string InstallDir
        {
            get { return Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "QUHAIM Labs", "QUHAIM Toolkit Pro"); }
        }

        private static void Install()
        {
            string installDir = InstallDir;
            string tempZip = Path.Combine(Path.GetTempPath(), "QUHAIMToolkitPro_payload_" + Guid.NewGuid().ToString("N") + ".zip");

            if (Directory.Exists(installDir))
            {
                Directory.Delete(installDir, true);
            }

            Directory.CreateDirectory(installDir);
            WriteEmbeddedPayload(tempZip);
            ZipFile.ExtractToDirectory(tempZip, installDir);
            File.Delete(tempZip);

            Directory.CreateDirectory(Path.Combine(installDir, "Installer"));
            File.Copy(Assembly.GetExecutingAssembly().Location, Path.Combine(installDir, "Installer", "QUHAIMToolkitProSetup.exe"), true);

            EnsureWritableDataFolders(installDir);
            ProtectProgramFiles(installDir);
            CreateShortcuts(installDir);
            RegisterUninstaller(installDir);
        }

        private static void WriteEmbeddedPayload(string targetPath)
        {
            Assembly asm = Assembly.GetExecutingAssembly();
            Stream source = null;

            foreach (string name in asm.GetManifestResourceNames())
            {
                if (name.EndsWith("payload.zip", StringComparison.OrdinalIgnoreCase))
                {
                    source = asm.GetManifestResourceStream(name);
                    break;
                }
            }

            if (source == null)
            {
                throw new InvalidOperationException("Installer payload was not found.");
            }

            using (source)
            using (FileStream target = File.Create(targetPath))
            {
                source.CopyTo(target);
            }
        }

        private static void EnsureWritableDataFolders(string installDir)
        {
            string[] folders = { "Data", "Logs", "Reports" };
            foreach (string folder in folders)
            {
                string path = Path.Combine(installDir, folder);
                Directory.CreateDirectory(path);
                GrantUsersModify(path);
            }
        }

        private static void ProtectProgramFiles(string installDir)
        {
            DirectorySecurity security = Directory.GetAccessControl(installDir);
            security.SetAccessRuleProtection(false, true);
            Directory.SetAccessControl(installDir, security);
        }

        private static void GrantUsersModify(string path)
        {
            SecurityIdentifier users = new SecurityIdentifier(WellKnownSidType.BuiltinUsersSid, null);
            DirectorySecurity security = Directory.GetAccessControl(path);
            FileSystemAccessRule rule = new FileSystemAccessRule(
                users,
                FileSystemRights.Modify,
                InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit,
                PropagationFlags.None,
                AccessControlType.Allow);
            security.AddAccessRule(rule);
            Directory.SetAccessControl(path, security);
        }

        private static void CreateShortcuts(string installDir)
        {
            string targetVbs = Path.Combine(installDir, "QUHAIMToolkitPro.vbs");
            string iconPath = Path.Combine(installDir, "Assets", "Branding", "quhaim-toolkit-pro.ico");
            string desktop = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
            string startMenu = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonStartMenu), "Programs", "QUHAIM Labs");
            Directory.CreateDirectory(startMenu);

            CreateShortcut(Path.Combine(desktop, "QUHAIM Toolkit Pro.lnk"), targetVbs, installDir, iconPath);
            CreateShortcut(Path.Combine(startMenu, "QUHAIM Toolkit Pro.lnk"), targetVbs, installDir, iconPath);
        }

        private static void CreateShortcut(string linkPath, string targetVbs, string workingDir, string iconPath)
        {
            Type shellType = Type.GetTypeFromProgID("WScript.Shell");
            dynamic shell = Activator.CreateInstance(shellType);
            dynamic shortcut = shell.CreateShortcut(linkPath);
            shortcut.TargetPath = "wscript.exe";
            shortcut.Arguments = "\"" + targetVbs + "\"";
            shortcut.WorkingDirectory = workingDir;
            shortcut.Description = ProductName;
            if (File.Exists(iconPath))
            {
                shortcut.IconLocation = iconPath;
            }
            shortcut.Save();
        }

        private static void RegisterUninstaller(string installDir)
        {
            string setupPath = Path.Combine(installDir, "Installer", "QUHAIMToolkitProSetup.exe");
            using (RegistryKey key = Registry.LocalMachine.CreateSubKey(UninstallKey))
            {
                key.SetValue("DisplayName", ProductName);
                key.SetValue("DisplayVersion", Version);
                key.SetValue("Publisher", Publisher);
                key.SetValue("InstallLocation", installDir);
                key.SetValue("DisplayIcon", Path.Combine(installDir, "Assets", "Branding", "quhaim-toolkit-pro.ico"));
                key.SetValue("UninstallString", "\"" + setupPath + "\" /uninstall");
                key.SetValue("NoModify", 1, RegistryValueKind.DWord);
                key.SetValue("NoRepair", 1, RegistryValueKind.DWord);
            }
        }

        private static void Uninstall()
        {
            string installDir = InstallDir;
            DeleteIfExists(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory), "QUHAIM Toolkit Pro.lnk"));
            DeleteIfExists(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonStartMenu), "Programs", "QUHAIM Labs", "QUHAIM Toolkit Pro.lnk"));
            Registry.LocalMachine.DeleteSubKeyTree(UninstallKey, false);

            string currentExe = Assembly.GetExecutingAssembly().Location;
            if (currentExe.StartsWith(installDir, StringComparison.OrdinalIgnoreCase))
            {
                Process.Start(new ProcessStartInfo("cmd.exe", "/c timeout /t 2 /nobreak >nul & rmdir /s /q \"" + installDir + "\"") { CreateNoWindow = true, WindowStyle = ProcessWindowStyle.Hidden });
            }
            else if (Directory.Exists(installDir))
            {
                Directory.Delete(installDir, true);
            }

            MessageBox.Show(ProductName + " was uninstalled.", ProductName, MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private static void DeleteIfExists(string path)
        {
            if (File.Exists(path))
            {
                File.Delete(path);
            }
        }
    }
}
