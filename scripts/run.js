const main = async () => {
  const [owner, randomPerson] = await hre.ethers.getSigners();
  const waveContractFactory = await hre.ethers.getContractFactory('WaveRoulette');
  const waveContract = await waveContractFactory.deploy({ value: hre.ethers.utils.parseEther('0.1') });
  await waveContract.deployed();

  console.log("Contract deployed to:", waveContract.address);
  console.log("Contract deployed by:", owner.address);

  let contractBalance = await hre.ethers.provider.getBalance(
    waveContract.address
  );
  console.log(
    'Contract balance:',
    hre.ethers.utils.formatEther(contractBalance)
  );

  let waveCount;
  waveCount = await waveContract.getTotalWaves();
  
  let waveTxn = await waveContract.wave('great stuff');
  await waveTxn.wait();

  waveTxn = await waveContract.connect(randomPerson).wave('awesome!');
  await waveTxn.wait();

  waveTxn = await waveContract.connect(randomPerson).wave('let me win!');
  await waveTxn.wait();

  contractBalance = await hre.ethers.provider.getBalance(waveContract.address);
  console.log(
    'Contract balance:',
    hre.ethers.utils.formatEther(contractBalance)
  );

  let winners = await waveContract.getWinners();
  console.log('Winners ', winners);

  waveCount = await waveContract.getTotalWaves();
  let waves = await waveContract.getAllWaves();
  console.log('Waves ', waves);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();