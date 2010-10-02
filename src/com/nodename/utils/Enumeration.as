/*Goals for enum implementation

finite: 

closed: programmer may neither add nor remove values at run time

generic: an enumerated type should not be required to extend any particular base class,
nor should its constructor be required to have any particular parameter types

derivable: ability to define a derived enumerated type each of whose values IS-A parent enumerated type

iterable: programmer should be able to iterate over the values of the type
or over the union of the values of more than one type (derived or not)

orderable: programmer should be able to specify an ordering on the set, or not

non-exclusive: programmer should be able to declare other public static members of the class that are not
included in the set of enumerated values, for example a default value referring to one of the enumerated values

serializable:  ability to write an enum value to a stream and read back the identical value object
*/


package com.nodename.utils
{
	import flash.utils.describeType;
	
	import flash.utils.Dictionary;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public final class Enumeration
	{
		private static var flexDescribeType:Function = null;
		private static const DescribeTypeCache:Class = getClassReference('mx.utils::DescribeTypeCache');
		if (DescribeTypeCache)
		{
			flexDescribeType = DescribeTypeCache["describeType"];
		}

		public function Enumeration()
		{
			throw new Error("Enumeration: no constructor");
		}
		
		/**
		 * @param enumClasses: one or more Classes
		 * This function requires that the enum values in each enumClass be static consts of type enumClass tagged with [Enum]
		 */
		public static function values(...enumClasses):Array
		{
			var result:Array = [];
			const length:uint = enumClasses.length;
			for (var i:uint = 0; i < length; i++)
			{
				const enumClass:Class = enumClasses[i] as Class;
				if (enumClass)
				{
					map(enumClass);
					result = result.concat(_valueListsByEnumClass[enumClass]);
				}
				else
				{
					throw new Error("Enum::values(): illegal argument");
				}
			}
			if (length > 1)
			{
				result.sort(compareOrdinals);
				// the individual value lists are already sorted
			}
			return result;
		}
		
		public static function ordinal(enumValue:Object):int
		{
			map(enumValue.constructor as Class);
			return _ordinalsByEnumValue[enumValue];
		}
		
		public static function nameOf(enumValue:Object):String
		{
			map(enumValue.constructor as Class);
			return _namesByEnumValue[enumValue];
		}
		
		public static function serialize(enumValue:Object, output:IDataOutput):Boolean
		{
			const valueName:String = nameOf(enumValue);
			if (valueName == null)
			{
				return false;
			}
			output.writeUTF(getQualifiedClassName(enumValue.constructor));
			output.writeUTF(valueName);
			return true;
		}
		
		public static function deserialize(input:IDataInput):*
		{
			const qualifiedClassName:String = input.readUTF();
			try
			{
				var owner:Class = getDefinitionByName(qualifiedClassName) as Class;
			}
			catch (error:Error)
			{
				return null;
			}
			
			try
			{
				const valueName:String = input.readUTF();
			}
			catch (error:Error)
			{
				return null;
			}
			
			return owner[valueName];
		}
		
		// enumClass -> Array of enumClass's values ordered by ordinal
		private static const _valueListsByEnumClass:Dictionary = new Dictionary(true);
		
		// enumValue -> its name
		// e.g. SomeClass.A -> "A"
		private static const _namesByEnumValue:Dictionary = new Dictionary(true);
		
		private static const _ordinalsByEnumValue:Dictionary = new Dictionary(true);
		
		private static const NOT_AN_ENUM_VALUE:int = int.MIN_VALUE;
		
		// enum values with no ordinal are sorted after those with an ordinal:
		private static const NO_ORDINAL:int = int.MAX_VALUE;
		
		
		private static function map(enumClass:Class):void
		{
			if (enumClass in _valueListsByEnumClass)
			{
				return;
			}
			
			var desc:XML;
			if (flexDescribeType != null)
			{
				desc = flexDescribeType(enumClass).typeDescription;
			}
			else
			{
				desc = describeType(enumClass);
			}
			
			const xmlTypeConstants:XMLList = desc.constant;
			const xmlNames:XMLList = xmlTypeConstants.@name;
			const valueList:Array = [];
			const length:uint = xmlNames.length();
			for (var i:uint = 0; i < length; i++)
			{
				const xmlName:XML = xmlNames[i];
				const constantName:String = xmlName.toString();
				const constantValue:* = enumClass[constantName];
				
				if (constantValue is enumClass)
				{
					const xmlTypeConstant:XML = xmlTypeConstants[i];
					const constantOrdinal:int = enumOrdinal(xmlTypeConstant);
					if (constantOrdinal != NOT_AN_ENUM_VALUE)
					{
						_ordinalsByEnumValue[constantValue] = constantOrdinal;
						_namesByEnumValue[constantValue] = constantName;
						valueList.push(constantValue);
					}
				}
			}
			if (valueList.length == 0)
			{
				throw new EnumerationError("no enum values detected in " + enumClass + ": did you tag them with [Enum]?");
			}
			
			valueList.sort(compareOrdinals);
			_valueListsByEnumClass[enumClass] = valueList;
			
			
			// When used to compare objects, the comparison operators <, >, >=, <= look for an instance method named "valueOf"
			// to determine the values;
			// but not the == and != operators, which compare Objects by reference, i.e. they must be the same object to be ==.
			//
			// Here we install our own valueOf() function (defined below, outside the package)
			// on the prototype of enumClass, so it will be invoked as if it were an instance method of enumClass,
			// and thus the comparison operators will work on all our enums.
			//
			// If you feel this is too twicky then comment it out. You can define it explicitly in your enum classes if you wish.
			enumClass.prototype.valueOf = valueOf;
			
			function enumOrdinal(node:XML):int
			{
				const enumMetadata:XML = node.metadata.(@name == "Enum")[0];
				if (enumMetadata)
				{
					const ordinalArg:XML = enumMetadata.arg.(@key == "ordinal")[0];
					if (ordinalArg)
					{
						return ordinalArg.@value;
					}
					return NO_ORDINAL;
				}
				return NOT_AN_ENUM_VALUE;
			}
		}
		
		private static function compareOrdinals(a:Object, b:Object):Number
		{
			const aOrdinal:int = _ordinalsByEnumValue[a];
			const bOrdinal:int = _ordinalsByEnumValue[b];
			
			if (aOrdinal > bOrdinal)
			{
				return 1;
			}
			if (aOrdinal < bOrdinal)
			{
				return -1;
			}
			return 0;
		}
	}
	
}

import com.nodename.utils.Enumeration;

function valueOf():Number { return Enumeration.ordinal(this); }