**Generate a PowerShell Function to Manage Linux System Services**

**Task Description:**

Create a PowerShell function that allows users to manage Linux system services, including starting, stopping, and restarting services. The function should be designed to work with Linux systems and should use the `systemctl` command to interact with the system services.

**Requirements:**

* The function should be named `Manage-LinuxService`
* The function should take the following parameters:
	+ `-ServiceName`: The name of the Linux system service to manage
	+ `-Action`: The action to perform on the service (start, stop, restart)
	+ `-Hostname`: The hostname or IP address of the Linux system
	+ `-Username`: The username to use for authentication
	+ `-Password`: The password to use for authentication
* The function should use the `systemctl` command to perform the specified action on the service
* The function should handle errors and exceptions elegantly, including authentication failures and service management errors
* The function should return a success message or an error message, depending on the outcome of the operation

**Guidelines:**

* Use the `CmdletBinding()` attribute to define the function's parameters and behavior
* Use the `param()` block to define the function's parameters
* Use the `try`-`catch` block to handle errors and exceptions
* Use the `Write-Host` cmdlet to output success and error messages
* Use the `systemctl` command to interact with the Linux system services
* Use the `ssh` command to connect to the Linux system and execute the `systemctl` command

**Example Output:**

The function should output a success message or an error message, depending on the outcome of the operation. For example:

* `Service 'httpd' started successfully on host 'linux-system'`
* `Error: Unable to start service 'httpd' on host 'linux-system': Authentication failed`

**Security Considerations:**

* The function should handle authentication credentials securely, using the `SecureString` class to store and transmit the password
* The function should use the `ssh` command to connect to the Linux system, using the `StrictHostKeyChecking` option to verify the host key