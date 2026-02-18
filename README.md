# AutoScanLocalIPs

The attached script is designed to gather ip information about the current computer's network adapters, and use it to find other active devices on the same local network.

Steps are broken down as follows
1. Collect running network adapters.
2. Get the current network adapter's IP address and Prefix length.
3. Calculate the prefix - (WIP as this is currently only set to accept the archaic Class A,B,C prefixs /8, /16 and /24 respectively.)
4. Use the known prefix to check all usable ips under the that prefix
5. Save responding ips to a .txt file in the same folder



Notes:
-Tried swapping this to run in parallel, but due to parallelization requiring far too much of an overhead for a tiny improvement to run-time, I will be reverting the script's loops back to sequential instead. Pretty sure I could force each ping and write to the file to run in asyncronous jobs, but will look into this after swapping back to sequential to get rid of the code clutter.