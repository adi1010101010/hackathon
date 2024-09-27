window.addEventListener('load', async () => {
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
});

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
    }
];

const web3 = new Web3(window.ethereum);
const donationContract = new web3.eth.Contract(contractABI, contractAddress);

document.getElementById('donateButton').addEventListener('click', async () => {
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
});

async function updateMyDonations() {
    const accounts = await web3.eth.getAccounts();
    const sender = accounts[0];
    const myDonations = await donationContract.methods.donations(sender).call();
    document.getElementById('myDonations').innerText = `Total Donations: ${web3.utils.fromWei(myDonations, 'ether')} Ether`;
}

async function updateAllDonations() {
    const donationTable = document.getElementById('donationTable');
    // Clear existing rows except header
    for (let i = donationTable.rows.length - 1; i > 0; i--) {
        donationTable.deleteRow(i);
    }

    // Get total donations to display (you might want to keep track of each donation separately)
    const totalDonations = await donationContract.methods.totalDonations().call();
    const totalDonor = await donationContract.methods.donations(sender).call(); // For example only, adjust based on your needs

    const row = donationTable.insertRow();
    row.insertCell(0).innerText = sender; // Replace with actual donor address if necessary
    row.insertCell(1).innerText = web3.utils.fromWei(totalDonations, 'ether') + ' Ether';
}
