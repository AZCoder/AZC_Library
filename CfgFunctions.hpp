class CfgFunctions
{
	class AZC
	{
		class Init
		{
			class InitLibrary {file = "AZC_Library\AZC_LIB\init.sqf";};
		};
		
		class AI
		{
			file = "AZC_Library\AZC_LIB\AI";
			class AddWaypoint {};
			class ClearWaypoints {};
			class FacePlayer {};
			class GetRelativeEyeDirection {};
			class HasLOS {};
			class React {};
			class ReactiveAI {};
			class RemoveReactHandlers {};
			class SetReactHandlers {};
			class Surrender {};
		};
		
		class damage
		{
			file = "AZC_Library\AZC_LIB\damage";
			class AddKiaFail {};
			class Explosion {};
			class Invincible {};
		};
		
		class debug
		{
			file = "AZC_Library\AZC_LIB\debug";
			class Debug {};
		};

		class fences
		{
			file = "AZC_Library\AZC_LIB\fences";
			class FenceCut {};
			class FenceInit {};
		};
		
		class gear
		{
			file = "AZC_Library\AZC_LIB\gear";
			class LoadGear {};
			class LoadWeaponCrate {};
			class SaveGear {};
		};
		
		class patrol
		{
			file = "AZC_Library\AZC_LIB\patrol";
			class APM {};
			class GetBuildings {};
			class GetNearestOpenBuilding {};
			class SetInteriorDestination {};
		};
		
		class spawning
		{
			file = "AZC_Library\AZC_LIB\spawning";
			class CreateLHD {};
			class CreateUnit {};
			class DoReplace {};
			class Replacer {};
			class SpawnMissile {};
		};
		
		class speech
		{
			file = "AZC_Library\AZC_LIB\speech";
			class Say {};
			class Say3D {};
			class Sound {};
			class Speak {};
		};
		
		class themes
		{
			file = "AZC_Library\AZC_LIB\themes";
			class SetAfghanTheme {};
			class SetBlackWhiteTheme {};
			class SetBlueTheme {};
			class SetColdTheme {};
			class SetColorfulTheme {};
			class SetGrayTheme {};
			class SetMiddleEastTheme {};
			class SetNightStalkersTheme {};
			class SetNormalTheme {};
			class SetPostApocolypseTheme {};
		};
		
		class utility
		{
			file = "AZC_Library\AZC_LIB\utility";
			class AddOnSafe {};
			class AddOnSafeClasses {};
			class AutoMarker {};
			class Cleanup {};
			class ClearJournal {};
			class Delete {};
			class ExtractClasses {};
			class Fadein {};
			class GetSpokenDate {};
			class GetSpokenDirection {};
			class Hibernate {};
			class ParadropVehicle {};
			class QuickSave {};
			class RemoveSnakes {};
		};
		
		class visual
		{
			file = "AZC_Library\AZC_LIB\visual";
			class ChimneyInit;
			class ChimneySmoke;
			class FogBreath {};
			class HouseLightsInit {};
			class IFF {};
			class IntroTitle {};
			class Light {};
			class ShowDate {};
			class ShowSubtitle2 {};
			class SITREP {};
		};
		
		class world
		{
			file = "AZC_Library\AZC_LIB\world";
			class GetPos {};
			class GetWeather {};
			class GetWorldStats {};
			class InsideBuilding {};
		};
	};
};
