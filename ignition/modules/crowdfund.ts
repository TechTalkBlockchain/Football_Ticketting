import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";




const CrowdFundModule = buildModule("CrowdFundModule", (m) => {

    const fund = m.contract("CrowdFunding");

    return { fund };
});

export default CrowdFundModule;
