package examples
{
	import com.nodename.utils.getClassReference;
	import com.nodename.utils.Enumeration;
	
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	public final class ACoupleOfEnumMembers implements IExternalizable
	{
		private static var ObjectUtilCopy:Function = null;
		private static const ObjectUtilClass:Class = getClassReference('mx.utils::ObjectUtil');
		if (ObjectUtilClass)
		{
			ObjectUtilCopy = ObjectUtilClass["copy"];
		}
		
		private var _anEnum:AnEnum;
		public function get anEnum():AnEnum { return _anEnum; }
		
		private var _anotherEnum:AnUnorderedEnum;
		public function get anotherEnum():AnUnorderedEnum { return _anotherEnum; }
		
		// in order to be serializable, a class that isn't an enum must have a constructor with no required arguments:
		public function ACoupleOfEnumMembers(anEnum:AnEnum=null, anotherEnum:AnUnorderedEnum=null)
		{
			_anEnum = anEnum;
			_anotherEnum = anotherEnum;
		}
		
		public function writeExternal(output:IDataOutput):void
		{
			Enumeration.serialize(_anEnum, output);
			Enumeration.serialize(_anotherEnum, output);
		}
		
		public function readExternal(input:IDataInput):void
		{
			_anEnum = Enumeration.deserialize(input);
			_anotherEnum = Enumeration.deserialize(input);
		}
		
		public function cloneBySerialization():ACoupleOfEnumMembers
		{
			if (ObjectUtilCopy != null)
			{
				// habemus Flex
				registerClassAlias('util.ACoupleOfEnumMembers', ACoupleOfEnumMembers);
				return ObjectUtilCopy(this) as ACoupleOfEnumMembers;
			}
			else
			{
				// just Flash
				const buffer:ByteArray = new ByteArray();
				writeExternal(buffer);
				buffer.position = 0;
				const result:ACoupleOfEnumMembers = new ACoupleOfEnumMembers();
				result.readExternal(buffer);
				return result;
			}
		}
		
		public function equals(other:ACoupleOfEnumMembers):Boolean
		{
			return _anEnum === other._anEnum && _anotherEnum === other._anotherEnum;
		}
	}
}