import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const FootballTickettingModule = buildModule("FootballTickettingModule", (m) => {
    
    const footballT = m.contract("FootballTicketBooking");

    return { footballT };
});

export default FootballTickettingModule;
