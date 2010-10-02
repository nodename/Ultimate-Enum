package 
{
	import com.nodename.utils.Enumeration;
	import com.nodename.utils.getClassName;
	
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	import org.hamcrest.object.IsNullMatcher;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.strictlyEqualTo;
	
	import examples.GenericThing;
	import examples.AnUnorderedEnum;
	import examples.AnEnum;
	import examples.ACoupleOfEnumMembers;
	import examples.SpecialThing;
	import examples.ADerivedEnum;
	
	public class EnumTestCase
	{
		public function EnumTestCase()
		{
			super();
		}
		
		[Before] public function setUp():void
		{
		}
		
		[After] public function tearDown():void
		{
		}
		
		[Test] public function comparisonOperatorWorks():void
		{
			assertThat(AnEnum.A < AnEnum.B);
		}
		
		[Test] public function comparisonOperatorOnRelatedTypesWorks():void
		{
			assertThat(AnEnum.A < ADerivedEnum.A);
			
			// These two objects' values (as returned by valueOf()) are equal:
			assertThat(AnEnum.A <= ADerivedEnum.B);
			assertThat(AnEnum.A >= ADerivedEnum.B);
			
			// but the objects are not identical:
			assertFalse(AnEnum.A == ADerivedEnum.B);
			assertFalse(AnEnum.A === ADerivedEnum.B);
			// when applied to Objects, == and === both compare by reference
			// (but they behave differently when comparing null and undefined)
		}
			
		/*
		This doesn't compile.  That is good.
		[Test] public function comparisonOperatorOnUnrelatedTypesDoesntCompile():void
		{
			assertThat( AnEnum.A < AnotherEnum.B);
		}*/
		
		[Test] public function enumNameWorks():void
		{
			assertThat(Enumeration.nameOf(AnEnum.A) == "A");
		}
		
		[Test] public function iterationOfOneEnumTypeWorks():void
		{
			const values:Array = Enumeration.values(AnEnum);
			trace();
			for each (var value:AnEnum in values)
			{
				trace(value);
			}
			trace();
			
			verifyOrdering(values);
			
			assertThat(values, equalTo([AnEnum.A, AnEnum.B, AnEnum.C, AnEnum.D]));
		}
		
		[Test] public function iterationOfrelatedEnumTypesWorks():void
		{
			const values:Array = Enumeration.values(GenericThing, SpecialThing);
			trace();
			for each (var value:GenericThing in values)
			{
				trace(getClassName(value) + "." + Enumeration.nameOf(value) + ": " + value);
			}
			trace();
			
			verifyOrdering(values);
		}
		
		private static function verifyOrdering(values:Array):void
		{
			const length:uint = values.length;
			for (var i:uint = 0; i < length - 1; i++)
			{
				assertThat(values[i] <= values[i + 1]);
			}
		}
		
		[Test] public function iterationOfUnrelatedEnumTypesWorks():void
		{
			const values:Array = Enumeration.values(AnEnum, AnUnorderedEnum);
			trace();
			for each (var value:Object in values)
			{
				trace(getClassName(value) + "." + Enumeration.nameOf(value));
			}
			trace();
			
			verifyOrdering(values);
			
			const length:uint = values.length;
			for (var i:uint = 0; i < length; i++)
			{
				assertThat(values[i] is AnEnum || AnUnorderedEnum);
			}
		}
		
		[Test] public function deserializationOfSerializedEnumReturnsIdenticalObject():void
		{
			const anEnum:AnEnum = AnEnum.B;
			const buffer:ByteArray = new ByteArray();
			const serialized:Boolean = Enumeration.serialize(anEnum, buffer);
			assertTrue(serialized);
			buffer.position = 0;
			const newEnum:AnEnum = Enumeration.deserialize(buffer);
			assertThat(newEnum, strictlyEqualTo(anEnum));
		}
		
		[Test(expects="com.nodename.utils.EnumerationError")] public function serializationOfBadEnumDoesntWork():void
		{
			const testString:String = "TestString";
			const buffer:ByteArray = new ByteArray();
			const serialized:Boolean = Enumeration.serialize(testString, buffer);
		}
		
		[Test] public function deserializationOfBadQualifiedClassNameReturnsNull():void
		{
			const testString:String = "TestString";
			const buffer:ByteArray = new ByteArray();
			buffer.writeUTF(testString);
			buffer.position = 0;
			const newString:String = Enumeration.deserialize(buffer);
			assertNull(newString);
		}
		
		[Test] public function deserializationOfMissingValueNameReturnsNull():void
		{
			const testString:String = getQualifiedClassName(AnEnum);
			const buffer:ByteArray = new ByteArray();
			buffer.writeUTF(testString);
			buffer.position = 0;
			const newString:String = Enumeration.deserialize(buffer);
			assertNull(newString);
		}
		
		[Test] public function serializationOfObjectWithEnumMembersWorks():void
		{
			const obj1:ACoupleOfEnumMembers = new ACoupleOfEnumMembers(AnEnum.A, AnUnorderedEnum.C);
			const obj2:ACoupleOfEnumMembers = obj1.cloneBySerialization();
			assertThat(obj1.equals(obj2));
		}
		
		[Test] public function deserializationOfSerializedDefaultValueReturnsTheValueItReferences():void
		{
			const defaultEnum:AnEnum = AnEnum.defaultValue;
			const buffer:ByteArray = new ByteArray();
			Enumeration.serialize(defaultEnum, buffer);
			buffer.position = 0;
			const newEnum:AnEnum = Enumeration.deserialize(buffer);
			assertThat(newEnum, strictlyEqualTo(AnEnum.A));
		}
		
	}
}