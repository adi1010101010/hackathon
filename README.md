html file source code:-
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Donation Platform</title>
    <link rel="stylesheet" href="style.css">

</head>

<body>
    <div class="container">
        <h1>Donation Platform</h1>
        <button id="connectWallet" onclick={connectWallet()}>Connect Wallet</button>
        <div id="walletAddress">Not Connected</div>
        <script>
            const connectWallet = async () => {
                if (typeof window.ethereum !== 'undefined') {
                    const web3 = new Web3(window.ethereum);
                    try {
                        await window.ethereum.request({ method: 'eth_requestAccounts' });
                        document.getElementById('connectWallet').innerText = 'Wallet Connected';
                        const accounts = await web3.eth.getAccounts();
                        document.getElementById('walletAddress').innerText = `Connected: ${accounts[0]}`;
                        updateMyDonations();
                        updateAllDonations();
                    } catch (error) {
                        console.error('User denied account access', error);
                    }
                } else {
                    alert('Please install MetaMask!');
                }
            }
        </script>
        
        <div class="form-group">
            <label for="donationAmountlabel">Donation Amount (in Ether):</label>
            <input type="number" id="donationAmount" placeholder="Enter Amount to Donate">
        </div>

        <button id="donateButton" onclick=donate()>Donate</button>
        <h3>My Donations</h3>
        <div id="myDonations"></div>

        <h3>All Donations</h3>
        <table id="donationTable">
            <tr>
                <th>Donor Address</th>
                <th>Amount (Ether)</th>
            </tr>
        </table>

        <div id="status"></div>
        <script>
            const contractAddress = '0x52C84043CD9c865236f11d9Fc9F56aa003c1f922'; // Replace with your contract address
            const contractABI = [
	{
		"inputs": [],
		"name": "donate",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "endTime",
				"type": "uint256"
			}
		],
		"name": "DonationEnded",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "donor",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "DonationReceived",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "startTime",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "endTime",
				"type": "uint256"
			}
		],
		"name": "DonationStarted",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "endDonation",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "endWithdrawal",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "durationInSeconds",
				"type": "uint256"
			}
		],
		"name": "startDonation",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "durationInSeconds",
				"type": "uint256"
			}
		],
		"name": "startWithdrawal",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "withdraw",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "Withdrawal",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "endTime",
				"type": "uint256"
			}
		],
		"name": "WithdrawalEnded",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "startTime",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "endTime",
				"type": "uint256"
			}
		],
		"name": "WithdrawalStarted",
		"type": "event"
	},
	{
		"stateMutability": "payable",
		"type": "receive"
	},
	{
		"inputs": [],
		"name": "donationActive",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "donationEndTime",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "donations",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "donationStartTime",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "totalDonations",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "withdrawalActive",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "withdrawalEndTime",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "withdrawalStartTime",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]
    
            const web3 = new Web3(window.ethereum);
            const donationContract = new web3.eth.Contract(contractABI, contractAddress);
            const donate = async () => {
                const amount = document.getElementById('donationAmount').value;
                const accounts = await web3.eth.getAccounts();
                const sender = accounts[0];
    
                if (amount <= 0) {
                    document.getElementById('status').innerText = 'Amount must be greater than 0.';
                    return;
                }
    
                try {
                    await donationContract.methods.donate().send({
                        from: sender,
                        value: web3.utils.toWei(amount, 'ether'),
                        gas: 3000000
                    });
    
                    document.getElementById('status').innerText = 'Donation successful!';
                    updateMyDonations();
                    updateAllDonations();
                } catch (error) {
                    document.getElementById('status').innerText = 'Donation failed. Check console for details.';
                    console.error('Donation failed:', error);
                }
            };
    
            // async function donateee
        </script>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/web3/dist/web3.min.js"></script>
</body>

</html>
