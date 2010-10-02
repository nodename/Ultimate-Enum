package
{
	import org.flexunit.internals.TraceListener;
	import org.flexunit.runner.FlexUnitCore;
	import org.fluint.uiImpersonation.IVisualEnvironmentBuilder;
	import org.fluint.uiImpersonation.VisualTestEnvironmentBuilder;

	import flash.display.Sprite;

	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="640", height="480")]

	public class EnumerationTestRunner extends Sprite {
		private var core : FlexUnitCore;

		public function EnumerationTestRunner() {
			//Instantiate the core.
			core = new FlexUnitCore();

			//This registers the stage with the VisualTestEnvironmentBuilder, which allows you
			//to use the UIImpersonator classes to add to the display list and remove from within your
			//tests. With Flex, this is done for you, but in AS projects it needs to be handled manually.
			const environmentBuilder : IVisualEnvironmentBuilder = VisualTestEnvironmentBuilder.getInstance(this);
			
			//Add any listeners. In this case, the TraceListener has been added to display results.
			core.addListener(new TraceListener());
			
			//There should be only 1 call to run().
			//You can pass a comma separated list (or an array) of tests or suites.
			//You can also pass a Request Object, which allows you to sort, filter and subselect.
			//var request:Request = Request.methods( someClass, ["method1", "method2", "method3"] ).sortWith( someSorter ).filterWith( someFilter );
			//core.run( request );
			core.run(EnumTestCase);
		}
	}
}
