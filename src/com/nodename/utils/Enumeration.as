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
		private static function describe(cls:Class):XML
		{
			if (flexDescribeType != null)
			{
				return flexDescribeType(cls).typeDescription;
			}
			else
			{
				return describeType(cls);
			}
		}

		public function Enumeration()
		{
			throw new Error("Enumeration: no constructor");
		}
		
		/**
		 * @param enumClasses: one or more Classes
		 * The enumerated type corresponding to an enumClass consists of the static consts of the enumClass
		 * that are of type enumClass and are tagged with [Enum]
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
					if (enumClass in _valueListsByEnumClass)
					{
						result = result.concat(_valueListsByEnumClass[enumClass]);
					}
					else
					{
						throw new EnumerationError("no enum values detected in " + enumClass + ": did you call Enumeration.registerClass()?");
					}
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
			return _ordinalsByEnumValue[enumValue];
		}
		
		public static function nameOf(enumValue:Object):String
		{
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
		
		// enumClass -> Array of enumClass's enumValues ordered by ordinal
		private static const _valueListsByEnumClass:Dictionary = new Dictionary(true);
		
		// enumValue -> its name
		// e.g. SomeClass.A -> "A"
		private static const _namesByEnumValue:Dictionary = new Dictionary(true);
		
		// enumValue -> its ordinal
		private static const _ordinalsByEnumValue:Dictionary = new Dictionary(true);
		
		// static consts with no enum tag are omitted from the enumList:
		private static const NO_ENUM_TAG:int = int.MIN_VALUE;
		
		// enum values with no ordinal are sorted after those with an ordinal:
		private static const NO_ORDINAL:int = int.MAX_VALUE;
		
		
		public static function registerClass(enumClass:Class):void
		{
			if (enumClass in _valueListsByEnumClass)
			{
				return;
			}
			
			var desc:XML = describe(enumClass);
			
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
					if (constantOrdinal != NO_ENUM_TAG)
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
			// Even if you do accept this, you can still hide this implementation by defining another valueOf() in the normal
			// way directly on any specific class.
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
				return NO_ENUM_TAG;
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