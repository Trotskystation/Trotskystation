import { Achievements } from './interfaces/Achievements';
import { AdvancedAirlockController } from './interfaces/AdvancedAirlockController';
import { AiAirlock } from './interfaces/AiAirlock';
import { AirAlarm } from './interfaces/AirAlarm';
import { AirlockElectronics } from './interfaces/AirlockElectronics';
import { Apc } from './interfaces/Apc';
import { AtmosAlertConsole } from './interfaces/AtmosAlertConsole';
import { AtmosControlConsole } from './interfaces/AtmosControlConsole';
import { AtmosFilter } from './interfaces/AtmosFilter';
import { AtmosMixer } from './interfaces/AtmosMixer';
import { AtmosPump } from './interfaces/AtmosPump';
import { BankMachine } from './interfaces/BankMachine';
import { BluespaceArtillery } from './interfaces/BluespaceArtillery';
import { BorgPanel } from './interfaces/BorgPanel';
import { BrigTimer } from './interfaces/BrigTimer';
import { Canister } from './interfaces/Canister';
import { Cargo, CargoExpress } from './interfaces/Cargo';
import { CellularEmporium } from './interfaces/CellularEmporium';
import { CentcomPodLauncher } from './interfaces/CentcomPodLauncher';
import { ChemDispenser } from './interfaces/ChemDispenser';
import { ChemHeater } from './interfaces/ChemHeater';
import { ChemMaster } from './interfaces/ChemMaster';
import { CodexGigas } from './interfaces/CodexGigas';
import { ComputerFabricator } from './interfaces/ComputerFabricator';
import { Crayon } from './interfaces/Crayon';
import { CrewConsole } from './interfaces/CrewConsole';
import { Cryo } from './interfaces/Cryo';
import { DisposalUnit } from './interfaces/DisposalUnit';
import { DnaVault } from './interfaces/DnaVault';
import { EngravedMessage } from './interfaces/EngravedMessage';
import { Gps } from './interfaces/Gps';
import { GravityGenerator } from './interfaces/GravityGenerator';
import { GulagItemReclaimer } from './interfaces/GulagItemReclaimer';
import { Holodeck } from './interfaces/Holodeck';
import { ImplantChair } from './interfaces/ImplantChair';
import { KeycardAuth } from './interfaces/KeycardAuth';
import { LanguageMenu } from './interfaces/LanguageMenu';
import { MechBayPowerConsole } from './interfaces/MechBayPowerConsole';
import { NtosArcade } from './interfaces/NtosArcade';
import { NtosMain } from './interfaces/NtosMain';
import { NtosNetDownloader } from './interfaces/NtosNetDownloader';
import { NtosSupermatterMonitor } from './interfaces/NtosSupermatterMonitor';
import { NtosWrapper } from './interfaces/NtosWrapper';
import { NuclearBomb } from './interfaces/NuclearBomb';
import { OperatingComputer } from './interfaces/OperatingComputer';
import { OreBox } from './interfaces/OreBox';
import { OreRedemptionMachine } from './interfaces/OreRedemptionMachine';
import { Pandemic } from './interfaces/Pandemic';
import { PersonalCrafting } from './interfaces/PersonalCrafting';
import { PortableGenerator } from './interfaces/PortableGenerator';
import { PortablePump, PortableScrubber } from './interfaces/PortableAtmos';
import { PowerMonitor } from './interfaces/PowerMonitor';
import { Radio } from './interfaces/Radio';
import { RapidPipeDispenser } from './interfaces/RapidPipeDispenser';
import { SatelliteControl } from './interfaces/SatelliteControl';
import { ScannerGate } from './interfaces/ScannerGate';
import { ShuttleManipulator } from './interfaces/ShuttleManipulator';
import { SmartVend } from './interfaces/SmartVend';
import { Smes } from './interfaces/Smes';
import { SmokeMachine } from './interfaces/SmokeMachine';
import { SolarControl } from './interfaces/SolarControl';
import { SpaceHeater } from './interfaces/SpaceHeater';
import { SpawnersMenu } from './interfaces/SpawnersMenu';
import { StationAlertConsole } from './interfaces/StationAlertConsole';
import { SuitStorageUnit } from './interfaces/SuitStorageUnit';
import { Tank } from './interfaces/Tank';
import { TankDispenser } from './interfaces/TankDispenser';
import { ThermoMachine } from './interfaces/ThermoMachine';
import { TurbineComputer } from './interfaces/TurbineComputer';
import { Uplink } from './interfaces/Uplink';
import { VaultController } from './interfaces/VaultController';
import { Wires } from './interfaces/Wires';
import { Guardian } from './interfaces/Guardian';
import { Autolathe } from './interfaces/Autolathe';

const ROUTES = {
  achievements: {
    component: () => Achievements,
    scrollable: true,
  },
  ai_airlock: {
    component: () => AiAirlock,
    scrollable: false,
  },
  advanced_airlock_controller: {
    component: () => AdvancedAirlockController,
    scrollabel: false,
  },
  airalarm: {
    component: () => AirAlarm,
    scrollable: true,
  },
  airlock_electronics: {
    component: () => AirlockElectronics,
    scrollable: false,
  },
  apc: {
    component: () => Apc,
    scrollable: false,
  },
  atmos_alert: {
    component: () => AtmosAlertConsole,
    scrollable: true,
  },
  atmos_control: {
    component: () => AtmosControlConsole,
    scrollable: true,
  },
  atmos_filter: {
    component: () => AtmosFilter,
    scrollable: false,
  },
  atmos_mixer: {
    component: () => AtmosMixer,
    scrollable: false,
  },
  atmos_pump: {
    component: () => AtmosPump,
    scrollable: false,
  },
  bank_machine: {
    component: () => BankMachine,
    scrollable: false,
  },
  borgopanel: {
    component: () => BorgPanel,
    scrollable: true,
  },
  brig_timer: {
    component: () => BrigTimer,
    scrollable: false,
  },
  bsa: {
    component: () => BluespaceArtillery,
    scrollable: false,
  },
  canister: {
    component: () => Canister,
    scrollable: false,
  },
  cargo: {
    component: () => Cargo,
    scrollable: true,
  },
  cargo_express: {
    component: () => CargoExpress,
    scrollable: true,
  },
  cellular_emporium: {
    component: () => CellularEmporium,
    scrollable: true,
  },
  centcom_podlauncher: {
    component: () => CentcomPodLauncher,
    scrollable: false,
  },
  chem_dispenser: {
    component: () => ChemDispenser,
    scrollable: true,
  },
  chem_heater: {
    component: () => ChemHeater,
    scrollable: true,
  },
  chem_master: {
    component: () => ChemMaster,
    scrollable: true,
  },
  codex_gigas: {
    component: () => CodexGigas,
    scrollable: false,
  },
  computer_fabricator: {
    component: () => ComputerFabricator,
    scrollable: false,
  },
  crayon: {
    component: () => Crayon,
    scrollable: true,
  },
  crew: {
    component: () => CrewConsole,
    scrollable: true,
  },
  cryo: {
    component: () => Cryo,
    scrollable: false,
  },
  disposal_unit: {
    component: () => DisposalUnit,
    scrollable: false,
  },
  dna_vault: {
    component: () => DnaVault,
    scrollable: false,
  },
  engraved_message: {
    component: () => EngravedMessage,
    scrollable: false,
  },
  gps: {
    component: () => Gps,
    scrollable: true,
  },
  gravity_generator: {
    component: () => GravityGenerator,
    scrollable: false,
  },
  gulag_item_reclaimer: {
    component: () => GulagItemReclaimer,
    scrollable: true,
  },
  holodeck: {
    component: () => Holodeck,
    scrollable: true,
  },
  implantchair: {
    component: () => ImplantChair,
    scrollable: false,
  },
  keycard_auth: {
    component: () => KeycardAuth,
    scrollable: false,
  },
  language_menu: {
    component: () => LanguageMenu,
    scrollable: true,
  },
  mech_bay_power_console: {
    component: () => MechBayPowerConsole,
    scrollable: false,
  },
  ntos_main: {
    component: () => NtosMain,
    wrapper: () => NtosWrapper,
    scrollable: true,
    theme: 'ntos',
  },
  ntos_net_downloader: {
    component: () => NtosNetDownloader,
    wrapper: () => NtosWrapper,
    scrollable: true,
    theme: 'ntos',
  },
  ntos_arcade: {
    component: () => NtosArcade,
    wrapper: () => NtosWrapper,
    scrollable: false,
    theme: 'ntos',
  },
  ntos_power_monitor: {
    component: () => PowerMonitor,
    wrapper: () => NtosWrapper,
    scrollable: true,
    theme: 'ntos',
  },
  ntos_supermatter_monitor: {
    component: () => NtosSupermatterMonitor,
    wrapper: () => NtosWrapper,
    scrollable: true,
    theme: 'ntos',
  },
  nuclear_bomb: {
    component: () => NuclearBomb,
    scrollable: false,
    theme: 'retro',
  },
  ore_redemption_machine: {
    component: () => OreRedemptionMachine,
    scrollable: true,
  },
  ore_box: {
    component: () => OreBox,
    scrollable: true,
  },
  operating_computer: {
    component: () => OperatingComputer,
    scrollable: true,
  },
  pandemic: {
    component: () => Pandemic,
    scrollable: true,
  },
  personal_crafting: {
    component: () => PersonalCrafting,
    scrollable: true,
  },
  portable_generator: {
    component: () => PortableGenerator,
    scrollable: false,
  },
  portable_pump: {
    component: () => PortablePump,
    scrollable: false,
  },
  portable_scrubber: {
    component: () => PortableScrubber,
    scrollable: false,
  },
  power_monitor: {
    component: () => PowerMonitor,
    scrollable: true,
  },
  radio: {
    component: () => Radio,
    scrollable: false,
  },
  rpd: {
    component: () => RapidPipeDispenser,
    scrollable: true,
  },
  sat_control: {
    component: () => SatelliteControl,
    scrollable: false,
  },
  scanner_gate: {
    component: () => ScannerGate,
    scrollable: true,
  },
  shuttle_manipulator: {
    component: () => ShuttleManipulator,
    scrollable: true,
  },
  smartvend: {
    component: () => SmartVend,
    scrollable: true,
  },
  smes: {
    component: () => Smes,
    scrollable: false,
  },
  smoke_machine: {
    component: () => SmokeMachine,
    scrollable: false,
  },
  solar_control: {
    component: () => SolarControl,
    scrollable: false,
  },
  space_heater: {
    component: () => SpaceHeater,
    scrollable: false,
  },
  spawners_menu: {
    component: () => SpawnersMenu,
    scrollable: true,
  },
  station_alert: {
    component: () => StationAlertConsole,
    scrollable: true,
  },
  suit_storage_unit: {
    component: () => SuitStorageUnit,
    scrollable: false,
  },
  tanks: {
    component: () => Tank,
    scrollable: false,
  },
  tank_dispenser: {
    component: () => TankDispenser,
    scrollable: false,
  },
  thermomachine: {
    component: () => ThermoMachine,
    scrollable: false,
  },
  turbine_computer: {
    component: () => TurbineComputer,
    scrollable: false,
  },
  uplink: {
    component: () => Uplink,
    scrollable: true,
    theme: 'syndicate',
  },
  vault_controller: {
    component: () => VaultController,
    scrollable: false,
  },
  wires: {
    component: () => Wires,
    scrollable: false,
  },
  guardian: {
    component: () => Guardian,
    scrollable: true,
  },
  autolathe: {
    component: () => Autolathe,
    scrollable: true,
  },
};

export const getRoute = state => {
  if (process.env.NODE_ENV !== 'production') {
    // Show a kitchen sink
    if (state.showKitchenSink) {
      const { KitchenSink } = require('./interfaces/KitchenSink');
      return {
        component: () => KitchenSink,
        scrollable: true,
      };
    }
  }
  // Refer to the routing table
  return ROUTES[state.config && state.config.interface];
};
